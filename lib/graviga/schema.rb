module Graviga
  class Schema
    def initialize(query: :Query, mutation: :Mutation, namespace: Object)
      @query = query
      @mutation = mutation
      @namespace = namespace
    end

    def execute(query, variables: nil, context: nil, operation: nil)
      @variables = variables
      @context = context
      @operation = operation

      doc = GraphQL.parse(query)

      operations = doc.definitions.select do |d|
        d.is_a? GraphQL::Language::Nodes::OperationDefinition
      end

      @fragments = doc.definitions.select do |d|
        d.is_a? GraphQL::Language::Nodes::FragmentDefinition
      end

      if @operation
        operation = operations.find do |operation_def|
          operation_def.name == @operation
        end
        unless operation
          raise Graviga::ExecutionError, "Unknown operation named \"#{@operation}\"."
        end
      elsif operations.size == 1
        operation = operations.first
      else
        raise Graviga::ExecutionError, 'Must provide operation name if query contains multiple operations.'
      end

      operation_name = operation_name_from(operation.operation_type)
      operation_type = get_type_class(operation_name).new

      data = {}
      extract_selections(operation.selections).each do |selection|
        data[(selection.alias || selection.name).to_sym] = resolve(operation_type, selection)
      end

      { data: data }
    rescue Graviga::ExecutionError => err
      { data: nil, errors: [err] }
    end

    private

    def extract_selections(selections, type = nil)
      selections.flat_map do |selection|
        next [] if skip_field?(selection)
        if selection.is_a? GraphQL::Language::Nodes::FragmentSpread
          fragment = @fragments.find { |f| f.name == selection.name }
          next [] if type && type.class.name.split("::").last.to_s != "#{fragment.type.to_s}Type"
          extract_selections(fragment.selections)
        elsif selection.is_a? GraphQL::Language::Nodes::InlineFragment
          next [] if type && type.class.name.split("::").last.to_s != "#{selection.type.to_s}Type"
          extract_selections(selection.selections)
        else
          selection
        end
      end
    end

    def operation_name_from(type_name)
      case type_name
      when 'query'    then @query
      when 'mutation' then @mutation
      end
    end

    def resolve(parent_type, selection, parent_obj = nil)
      name = selection.name
      field = parent_type.field(name)

      type_def = field[:type]
      args_def = field[:options][:args]
      non_null = false
      is_array = false
      non_null_item = false

      if type_def[-1] == '!'
        non_null = true
        type_def = type_def[0...-1].to_sym
      end

      if type_def[0] == '[' && type_def[-1] == ']'
        is_array = true
        type_def = type_def[1...-1]

        if type_def[-1] == '!'
          non_null_item = true
          type_def = type_def[0...-1].to_sym
        end
      end

      obj = nil
      if parent_type.respond_to?(name)
        parent_type.instance_variable_set(:@source, parent_obj)
        parent_type.instance_variable_set(:@context, @context)
        if args_def
          args = get_args(name, selection.arguments, args_def)
          obj = parent_type.public_send(name, args)
        else
          obj = parent_type.public_send(name)
        end
      elsif parent_obj.respond_to?(name)
        obj = parent_obj.public_send(name)
      end

      if obj.nil?
        if non_null
          parent_type_name = parent_type.class.name.split("::").last
          raise Graviga::ExecutionError, "Cannot return null for non-nullable field #{parent_type_name}.#{name}"
        else
          return nil
        end
      end

      type_klass = get_type_class(type_def)
      if type_klass < Graviga::Types::UnionType || type_klass < Graviga::Types::InterfaceType
        type_klass = get_type_class(type_klass.new.resolve_type(obj))
      end
      type = type_klass.new

      if is_array
        return obj.map do |o|
          if o.nil? && non_null_item
            parent_type_name = parent_type.class.name.split("::").last
            raise Graviga::ExecutionError, "Cannot return null for non-nullable field #{parent_type_name}.#{name}"
          end

          if type.is_a?(Graviga::Types::ScalarType) || type.is_a?(Graviga::Types::EnumType)
            type.serialize(o)
          else
            extract_selections(selection.selections, type).map do |s|
              [(s.alias || s.name).to_sym, resolve(type, s, o)]
            end.compact.to_h
          end
        end
      end

      if type.is_a?(Graviga::Types::ScalarType) || type.is_a?(Graviga::Types::EnumType)
        type.serialize(obj)
      elsif type.is_a? Graviga::Types::ObjectType
        extract_selections(selection.selections, type).map do |s|
          [(s.alias || s.name).to_sym, resolve(type, s, obj)]
        end.compact.to_h
      else
        raise Graviga::ExecutionError, "#{type_def} is invalid type"
      end
    end

    def get_type_class(name)
      if Graviga::Types.built_in? name
        Graviga::Types.const_get("#{name}Type")
      else
        @namespace.const_get("#{name}Type")
      end
    end

    def get_args(field_name, arguments, args_def)
      args = arguments.map do |s|
        [s.name.to_sym, s.value]
      end.to_h

      args_def.map do |name, type_def|
        val = args[name]

        if val.is_a? GraphQL::Language::Nodes::VariableIdentifier
          val = @variables[val.name.to_sym]
        end

        non_null = false
        is_array = false
        non_null_item = false

        if type_def[-1] == '!'
          non_null = true
          type_def = type_def[0...-1].to_sym
        end

        if type_def[0] == '[' && type_def[-1] == ']'
          is_array = true
          type_def = type_def[1...-1]

          if type_def[-1] == '!'
            non_null_item = true
            type_def = type_def[0...-1].to_sym
          end
        end

        if val.nil?
          if non_null
            raise Graviga::ExecutionError,
              "Field \"#{field_name}\" argument \"#{name}\" of type \"#{type_def}!\" is required but not provided."
          else
            next [name, nil]
          end
        end

        type_klass = get_type_class(type_def)
        type = type_klass.new

        if is_array
          val = val.map do |v|
            if type.is_a? Graviga::Types::ScalarType
              type.parse(v)
            elsif type.is_a? Graviga::Types::EnumType
              v.is_a?(GraphQL::Language::Nodes::Enum) ? type.parse(v.name) : type.parse(v)
            elsif type.is_a? Graviga::Types::InputObjectType
              get_args(name, v.arguments, type.to_h)
            end
          end
        elsif type.is_a? Graviga::Types::EnumType
          val = val.is_a?(GraphQL::Language::Nodes::Enum) ? type.parse(val.name) : type.parse(val)
        elsif type.is_a? Graviga::Types::ScalarType
          val = type.parse(val)
        elsif type.is_a? Graviga::Types::InputObjectType
          val = get_args(name, val.arguments, type.to_h)
        end

        [name, val]
      end.to_h
    end

    def skip_field?(selection)
      return false if selection.directives.nil? || selection.directives.empty?

      directive = selection.directives.first
      if_value = directive.arguments.find { |a| a.name == 'if' }.value

      if if_value.is_a? GraphQL::Language::Nodes::VariableIdentifier
        if_value = @variables[if_value.name.to_sym]
      end

      if directive.name == 'skip' && if_value
        return true
      end

      if directive.name == 'include' && !if_value
        return true
      end

      return false
    end
  end
end
