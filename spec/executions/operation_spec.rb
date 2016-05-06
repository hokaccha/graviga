require 'spec_helper'

describe 'operation' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :foo, :String
        field :bar, :String

        def foo
          'query-foo'
        end

        def bar
          'query-bar'
        end
      end

      class MutationType < Graviga::Types::ObjectType
        field :foo, :String
        field :bar, :String

        def foo
          'mutation-foo'
        end

        def bar
          'mutation-bar'
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, mutation: :Mutation, namespace: Sandbox) }
  let(:operation) { nil }

  subject(:data) { schema.execute(query, operation: operation)[:data] }
  subject(:error) { schema.execute(query, operation: operation)[:errors][0] }

  context 'when defined anonymous single query' do
    let(:query) { '{ foo }' }
    it { expect(data).to eq foo: 'query-foo' }
  end

  context 'when defined anonymous single mutation' do
    let(:query) { 'mutation { foo }' }
    it { expect(data).to eq foo: 'mutation-foo' }
  end

  context 'when specified unknown operation' do
    let(:query) { 'query a { foo }' }
    let(:operation) { 'b' }
    it { expect(error).to be_a Graviga::ExecutionError }
    it { expect(error.message).to eq 'Unknown operation named "b".' }
  end

  context 'when defined multiple queries' do
    let(:query) do
      '
      query a { foo }
      query b { bar }
      mutation c { foo }
      mutation d { bar }
      '
    end

    context 'when operation name is a' do
      let(:operation) { 'a' }
      it { expect(data).to eq foo: 'query-foo' }
    end

    context 'when operation name is b' do
      let(:operation) { 'b' }
      it { expect(data).to eq bar: 'query-bar' }
    end

    context 'when operation name is c' do
      let(:operation) { 'c' }
      it { expect(data).to eq foo: 'mutation-foo' }
    end

    context 'when operation name is d' do
      let(:operation) { 'd' }
      it { expect(data).to eq bar: 'mutation-bar' }
    end

    context 'when operation is not specified' do
      it { expect(error).to be_a Graviga::ExecutionError }
      it { expect(error.message).to eq 'Must provide operation name if query contains multiple operations.' }
    end
  end
end
