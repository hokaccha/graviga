module Graviga
  module Types
    class InterfaceType
      def self.field(name, type, options = {})
        @fields ||= {}
        @fields[name] = { name: name, type: type, options: options }
      end

      def resolve_type(*)
        raise NotImplementedError
      end
    end
  end
end
