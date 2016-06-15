require 'spec_helper'

describe 'hello world' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :hello, :String!
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  subject { schema.to_graphql }

  it do
    should eq <<~GRAPHQL.strip
      schema {
        query: Query
      }

      type Query {
        hello: String!
      }
    GRAPHQL
  end
end
