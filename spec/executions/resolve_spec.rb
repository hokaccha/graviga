require 'spec_helper'
require 'hashie'

describe 'resolve' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :foo, :String
        field :arr, :'[Obj]'
        field :obj, :Obj

        def foo
          'foo'
        end

        def arr
          [
            Hashie::Mash.new({ x: 'x1' }),
            Hashie::Mash.new({ x: 'x2' }),
          ]
        end

        def obj
          Hashie::Mash.new({ x: 'x' })
        end
      end

      class ObjType < Graviga::Types::ObjectType
        field :x, :String
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:query) { '{ foo, arr { x }, obj { x } }' }

  subject { schema.execute(query) }

  it do
    should eq(
      data: {
        foo: 'foo',
        arr: [
          { x: 'x1' },
          { x: 'x2' },
        ],
        obj: { x: 'x' }
      }
    )
  end
end
