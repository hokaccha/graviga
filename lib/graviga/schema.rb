module Graviga
  class Schema
    def initialize(*)
    end

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
