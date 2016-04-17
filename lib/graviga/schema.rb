module Graviga
  module Schema
    def self.included(klass)
      klass.extend ModuleMethods
      klass.include Graviga::Types
    end

    module ModuleMethods
      def execute(*)
        {
          'data' => {
            'post' => {
              'id' => '1',
              'title' => 'foo',
            },
          },
        }
      end
    end
  end
end
