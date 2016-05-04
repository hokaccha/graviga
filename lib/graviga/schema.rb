module Graviga
  class Schema
    def initialize(query:, namespace: Object)
      @query = query
      @namespace = namespace
    end

    def execute(query)
      data = {}
      type = get_type_class(@query).new
      doc = GraphQL.parse(query)
      doc.definitions.each do |part|
        part.selections.each do |selection|
          data[selection.name.to_sym] = resolve(type, selection)
        end
      end

      { data: data }
    rescue Graviga::ExecutionError => err
      { data: nil, errors: [err] }
    end

    private

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
      arguments.map do |s|
        key = s.name.to_sym
        val = s.value
        type_def = args_def[key]
        non_null = false
        if type_def[-1] == '!'
          non_null = true
          type_def = type_def[0...-1].to_sym
        end

        if non_null && val.nil?
          raise Graviga::ExecutionError,
            "Field \"#{field_name}\" argument \"#{key}\" of type \"#{type_def}!\" is required but not provided."
        end

        type_klass = get_type_class(type_def)
        type = type_klass.new
        val = type.parse(val)

        [key, val]
      end.to_h
    end
  end
end
