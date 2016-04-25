module Graviga
  module Types
    class StringType < ScalarType
      def serialize(value)
        value.to_s
      end

      def parse(value)
        value.to_s
      end
    end
  end
end
