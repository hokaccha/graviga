module Graviga
  module Types
    class ObjectType
      attr_reader :source

      def self.field(name, type, options = {})
        @fields ||= {}
        @fields[name] = { name: name, type: type, options: options }
      end

      def field(name)
        self.class.instance_variable_get(:@fields)[name.to_sym]
      end
    end
  end
end
