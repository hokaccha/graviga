require 'spec_helper'

describe 'input object type' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :echo, :String, args: { foo: :FooInput, x: :String }

        def echo(args)
          args.to_s
        end
      end

      class FooInputType < Graviga::Types::InputObjectType
        field :bar, :BarInput
        field :y, :String
      end

      class BarInputType < Graviga::Types::InputObjectType
        field :z, :String
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:query) { '{ echo(foo: { bar: { z: "z" }, y: "y" }, x: "x") }' }

  subject { schema.execute(query) }

  it { should eq({ data: { echo: { foo: { bar: { z: 'z' }, y: 'y' }, x: 'x' }.to_s } }) }
end
