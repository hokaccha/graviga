module Graviga
  module Schema
    def self.included(klass)
      klass.extend ModuleMethods
      klass.include Graviga::Types
    end

    module ModuleMethods
      def execute(query)
        data = {}
        type = self::QueryType.new
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
        non_null = false
        is_array = false
        if type_def.is_a? Array
          is_array = true
          type_def = type_def.first
        end

        if /!$/ === type_def
          non_null = true
          type_def = type_def[0...-1].to_sym
        end

        type_klass = self.const_get("#{type_def}Type")
        type = type_klass.new

        obj = nil
        if parent_type.respond_to?(name)
          obj = parent_type.send(name, parent_obj)
        elsif parent_obj.respond_to?(name)
          obj = parent_obj.send(name)
        end

        if non_null && obj.nil?
          parent_type_name = parent_type.class.name.split("::").last.sub(/Type$/, '')
          raise Graviga::ExecutionError, "Cannot return null for non-nullable field #{parent_type_name}.#{name}."
        end

        if type.is_a? Graviga::Types::ScalarType
          if is_array
            obj.map { |o| type.serialize(o) }
          else
            type.serialize(obj)
          end
        elsif is_array
          obj.map do |o|
            selection.selections.map do |s|
              [s.name.to_sym, resolve(type, s, o)]
            end.to_h
          end
        else
          selection.selections.map do |s|
            [s.name.to_sym, resolve(type, s, obj)]
          end.to_h
        end
      end
    end
  end
end
