module Graviga
  module Types
    class IDType < ScalarType
      def serialize(value)
        value.to_s
      end

      def parse(value)
        value.to_s
      end
    end
  end
end
