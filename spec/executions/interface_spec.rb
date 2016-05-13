require 'spec_helper'

describe 'interface' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :x, :Named

        def x
          # resolved by stub
        end
      end

      class NamedType < Graviga::Types::InterfaceType
        field :name, :String

        def resolve_type(value)
          value[:type]
        end
      end

      class FooType < Graviga::Types::ObjectType
        implement :Named

        field :name, :String

        def name
          'foo'
        end
      end

      class BarType < Graviga::Types::ObjectType
        implement :Named

        field :name, :String

        def name
          'bar'
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:query) { nil }
  let(:resolve_type) { nil }

  before do
    allow_any_instance_of(Sandbox::QueryType).to receive(:x).and_return(type: resolve_type)
  end

  subject { schema.execute(query) }

  context do
    let(:resolve_type) { :Foo }
    let(:query) { '{ x { name } }' }
    it { should eq({ data: { x: { name: 'foo' } } }) }
  end

  context do
    let(:resolve_type) { :Bar }
    let(:query) { '{ x { name } }' }
    it { should eq({ data: { x: { name: 'bar' } } }) }
  end

  context do
    let(:resolve_type) { :Foo }
    let(:query) { '{ x { ... on Foo { name } } }' }
    it { should eq({ data: { x: { name: 'foo' } } }) }
  end

  context do
    let(:resolve_type) { :Foo }
    let(:query) { '{ x { ... on Bar { name } } }' }
    it { should eq({ data: { x: {} } }) }
  end
end
