require 'spec_helper'

describe 'input object type' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :echo, :String, args: { a1: :'[FooInput]', a2: :'[String]' }

        def echo(args)
          args.to_s
        end
      end

      class FooInputType < Graviga::Types::InputObjectType
        field :x, :'[String]'
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:query) { '{ echo(a1: [{ x: ["1", "2"] }, { x: ["3"] }], a2: ["3", "4"]) }' }

  subject { schema.execute(query) }

  it { should eq({ data: { echo: { a1: [{ x: ["1", "2"] }, { x: ["3"] }], a2: ["3", "4"] }.to_s } }) }
end
