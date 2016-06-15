module Graviga
  class SchemaPrinter
    attr_accessor :schema

    def initialize(schema)
      self.schema = schema
    end

    def print_schema
      result = []
      result << format_root_schema
      result << format_type(schema.query)
      result.join "\n\n"
    end

    def format_root_schema
      types = {}
      if schema.query
        types[:query] = schema.query
      end

      if schema.mutation
        types[:mutation] = schema.mutation
      end

      format('schema', types)
    end

    def format_type(type_name)
      type_class = schema.namespace.const_get "#{type_name}Type"
      types = type_class.fields.map do |name, val|
        [name, val[:type]]
      end.to_h
      format("type #{type_name}", types)
    end

    def format(name, types)
      line = []
      line << "#{name} {"
      types.each do |key, val|
        line << "  #{key}: #{val}"
      end
      line << "}"
      line.join "\n"
    end
  end
end
