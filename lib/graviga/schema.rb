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

      if @operation
        operation = doc.definitions.find do |operation_def|
          operation_def.name == @operation
        end
        unless operation
          raise Graviga::ExecutionError, "Unknown operation named \"#{@operation}\"."
        end
      elsif doc.definitions.size == 1
        operation = doc.definitions.first
      else
        raise Graviga::ExecutionError, 'Must provide operation name if query contains multiple operations.'
      end

      operation_name = operation_name_from(operation.operation_type)
      operation_type = get_type_class(operation_name).new

      data = {}
      operation.selections.each do |selection|
        data[selection.name.to_sym] = resolve(operation_type, selection)
      end

      { data: data }
    rescue Graviga::ExecutionError => err
      { data: nil, errors: [err] }
    end

    private

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
          obj = parent_type.send(name, args)
        else
          obj = parent_type.send(name)
        end
      elsif parent_obj.respond_to?(name)
        obj = parent_obj.send(name)
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
      type = type_klass.new

      if is_array
        return obj.map do |o|
          if o.nil? && non_null_item
            parent_type_name = parent_type.class.name.split("::").last
            raise Graviga::ExecutionError, "Cannot return null for non-nullable field #{parent_type_name}.#{name}"
          end

          if type.is_a? Graviga::Types::ScalarType
            type.serialize(o)
          else
            selection.selections.map do |s|
              [s.name.to_sym, resolve(type, s, o)]
            end.to_h
          end
        end
      end

      if type.is_a? Graviga::Types::ScalarType
        type.serialize(obj)
      elsif type.is_a? Graviga::Types::ObjectType
        selection.selections.map do |s|
          [s.name.to_sym, resolve(type, s, obj)]
        end.to_h
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

        if non_null && val.nil?
          raise Graviga::ExecutionError,
            "Field \"#{field_name}\" argument \"#{name}\" of type \"#{type_def}!\" is required but not provided."
        end

        type_klass = get_type_class(type_def)
        type = type_klass.new

        if is_array
          val = val.map do |v|
            if type.is_a? Graviga::Types::ScalarType
              type.parse(v)
            elsif type.is_a? Graviga::Types::InputObjectType
              get_args(name, v.arguments, type.to_h)
            end
          end
        elsif type.is_a? Graviga::Types::ScalarType
          val = type.parse(val)
        elsif type.is_a? Graviga::Types::InputObjectType
          val = get_args(name, val.arguments, type.to_h)
        end

        [name, val]
      end.to_h
    end
  end
end
