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

        if parent_type.respond_to?(name)
          obj = parent_type.send(name, parent_obj)
        else
          obj = parent_obj.send(name)
        end

        return obj if selection.selections.empty?

        if is_array
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
