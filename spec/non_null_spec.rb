require 'spec_helper'

describe 'non null' do
  module TestSchema
    include Graviga::Schema
    class QueryType < ObjectType
      field :foo, :String!
      field :bar, :String!

      def foo(_)
        nil
      end
    end
  end

  specify do
    result = TestSchema.execute('{ foo }')
    errors = result[:errors]
    error = errors.first
    expect(errors.size).to eq 1
    expect(error).to be_a Graviga::ExecutionError
    expect(error.message).to eq 'Cannot return null for non-nullable field Query.foo.'

    result = TestSchema.execute('{ bar }')
    errors = result[:errors]
    error = errors.first
    expect(errors.size).to eq 1
    expect(error).to be_a Graviga::ExecutionError
    expect(error.message).to eq 'Cannot return null for non-nullable field Query.bar.'
  end
end
