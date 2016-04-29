require 'spec_helper'

describe 'hello world' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :hello, :String!
        def hello
          'world'
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:result) { schema.execute('{ hello }') }

  it { expect(result).to eq({ data: { hello: 'world' } }) }
end
