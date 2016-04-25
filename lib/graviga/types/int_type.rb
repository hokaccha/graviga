module Graviga
  module Types
    class IntType < ScalarType
      def serialize(value)
        value.to_i
      end

      def parse(value)
        value.to_i
      end
    end
  end
end
