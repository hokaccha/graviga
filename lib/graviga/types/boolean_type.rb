module Graviga
  module Types
    class BooleanType < ScalarType
      def serialize(value)
        !!value
      end

      def parse(value)
        !!value
      end
    end
  end
end
