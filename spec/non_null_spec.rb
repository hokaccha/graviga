require 'spec_helper'

describe 'non null' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :foo, :String!
        field :bar, :String!

        def foo
          nil
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

  specify do
    result = schema.execute('{ foo }')
    errors = result[:errors]
    error = errors.first
    expect(errors.size).to eq 1
    expect(error).to be_a Graviga::ExecutionError
    expect(error.message).to eq 'Cannot return null for non-nullable field Query.foo.'

    result = schema.execute('{ bar }')
    errors = result[:errors]
    error = errors.first
    expect(errors.size).to eq 1
    expect(error).to be_a Graviga::ExecutionError
    expect(error.message).to eq 'Cannot return null for non-nullable field Query.bar.'
  end

  context 'when foo returns some value' do
    before do
      allow_any_instance_of(Sandbox::QueryType).to receive(:foo).and_return('x')
    end

    it 'should not be error' do
      result = schema.execute('{ foo }')
      expect(result).to eq({ data: { foo: 'x' } })
    end
  end
end
