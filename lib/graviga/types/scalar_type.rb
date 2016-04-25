module Graviga
  module Types
    class ScalarType
      def serialize(*)
        raise NotImplementedError
      end

      def parse(*)
        raise NotImplementedError
      end
    end
  end
end
