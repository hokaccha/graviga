module Graviga
  module Types
    class FloatType < ScalarType
      def serialize(value)
        value.to_f
      end

      def parse(value)
        value.to_f
      end
    end
  end
end
