module Graviga
  module Types
    class ObjectType
      attr_reader :source
      attr_reader :context

      def self.field(name, type, options = {})
        @fields ||= {}
        @fields[name] = { name: name, type: type, options: options }
      end

      def self.fields
        @fields
      end

      def self.implement(*interfaces)
        @interfaces ||= []
        @interfaces += interfaces
      end

      def field(name)
        self.class.instance_variable_get(:@fields)[name.to_sym]
      end
    end
  end
end
