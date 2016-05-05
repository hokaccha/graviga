module Graviga
  module Types
    class InputObjectType
      def self.field(name, type, options = {})
        @fields ||= {}
        @fields[name] = { name: name, type: type, options: options }
      end

      def to_h
        self.class.instance_variable_get(:@fields).map do |name, field|
          [name, field[:type]]
        end.to_h
      end
    end
  end
end
