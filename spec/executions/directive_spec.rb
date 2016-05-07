require 'spec_helper'
require 'hashie'

describe 'directive' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :foo, :String
        field :bar, :String
        field :arr, :'[Obj]'
        field :obj, :Obj

        def foo
          'foo'
        end

        def bar
          'bar'
        end

        def arr
          [
            Hashie::Mash.new({ x: 'x1', y: 'y1' }),
            Hashie::Mash.new({ x: 'x2', y: 'y2' }),
          ]
        end

        def obj
          Hashie::Mash.new({ x: 'x', y: 'y' })
        end
      end

      class ObjType < Graviga::Types::ObjectType
        field :x, :String
        field :y, :String
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

  subject { schema.execute(query, variables: variables)[:data] }

  context 'scalar' do
    let(:query) do
      '
      query($a: Boolean!, $b: Boolean!) {
        foo @skip(if: $a)
        bar @include(if: $b)
      }
      '
    end

    context do
      let(:variables) { { a: false, b: true } }
      it { should eq({ foo: 'foo', bar: 'bar' }) }
    end

    context do
      let(:variables) { { a: true, b: true } }
      it { should eq({ bar: 'bar' }) }
    end

    context do
      let(:variables) { { a: false, b: false } }
      it { should eq({ foo: 'foo' }) }
    end
  end

  context 'arr' do
    let(:query) do
      '
      query($a: Boolean!) {
        arr {
          x @skip(if: $a)
          y
        }
      }
      '
    end

    context do
      let(:variables) { { a: false } }
      it { should eq(arr: [{ x: 'x1', y: 'y1' }, { x: 'x2', y: 'y2' }]) }
    end

    context do
      let(:variables) { { a: true } }
      it { should eq(arr: [{ y: 'y1' }, { y: 'y2' }]) }
    end
  end

  context 'obj' do
    let(:query) do
      '
      query($a: Boolean!) {
        obj {
          x @skip(if: $a)
          y
        }
      }
      '
    end

    context do
      let(:variables) { { a: false } }
      it { should eq(obj: { x: 'x', y: 'y' }) }
    end

    context do
      let(:variables) { { a: true } }
      it { should eq(obj: { y: 'y' }) }
    end
  end
end
