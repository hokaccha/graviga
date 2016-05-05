require 'spec_helper'

describe 'input object type' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :echo, :String, args: { foo: :FooInput }

        def echo(args)
          args[:foo][:bar][:baz]
        end
      end

      class FooInputType < Graviga::Types::InputObjectType
        field :bar, :BarInput
      end

      class BarInputType < Graviga::Types::InputObjectType
        field :baz, :String
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:query) { '{ echo(foo: { bar: { baz: "x" } }) }' }

  subject { schema.execute(query) }

  it { should eq({ data: { echo: "x" } }) }
end
