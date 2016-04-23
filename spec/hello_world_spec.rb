require 'spec_helper'

describe 'hello world' do
  module HelloWorldSchema
    include Graviga::Schema

    class Query < ObjectType
      field :hello, :string!

      def hello
        'world'
      end
    end
  end

  specify do
    result = HelloWorldSchema.execute('{ hello }')
    expect(result).to eq({ data: { hello: 'world' } })
  end
end
