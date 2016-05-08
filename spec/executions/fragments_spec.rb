require 'spec_helper'

describe 'fragments' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :obj, :Obj

        def obj
          {}
        end
      end

      class ObjType < Graviga::Types::ObjectType
        field :foo, :String
        field :bar, :String
        field :baz, :String

        def foo
          'foo'
        end

        def bar
          'bar'
        end

        def baz
          'baz'
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

  subject { schema.execute(query) }

  context do
    let(:query) do
      '
      { ...a }
      fragment a on Query { obj { ...b } }
      fragment b on Obj { foo, bar }
      '
    end

    it { should eq(data: { obj: { foo: 'foo', bar: 'bar' } }) }
  end

  context do
    let(:query) do
      '
      {
        ... on Query {
          obj {
            ... on Obj {
              foo
              bar
            }
          }
        }
      }
      '
    end

    it { should eq(data: { obj: { foo: 'foo', bar: 'bar' } }) }
  end
end
