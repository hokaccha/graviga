require 'spec_helper'

describe 'hello world' do
  module HelloWorldSchema
    include Graviga::Schema

    class QueryType < ObjectType
      field :hello, :String!

      def hello(_)
        'world'
      end
    end
  end

  specify do
    result = HelloWorldSchema.execute('{ hello }')
    expect(result).to eq({ data: { hello: 'world' } })
  end
end
