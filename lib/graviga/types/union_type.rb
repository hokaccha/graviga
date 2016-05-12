module Graviga
  module Types
    class UnionType
      def self.types(*type_names)
        @type_names = type_names
      end

      def resolve_type(*)
        raise NotImplementedError
      end
    end
  end
end
