require 'spec_helper'

describe 'field_alias' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :str, :String
        field :arr, :'[Obj]'
        field :obj, :Obj

        def str
          'str'
        end

        def arr
          [{}, {}]
        end

        def obj
          {}
        end
      end

      class ObjType < Graviga::Types::ObjectType
        field :x, :String

        def x
          'x'
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

  subject { schema.execute(query) }

  context do
    let(:query) { '{ str1: str, str2: str, str }' }
    it { should eq({ data: { str1: 'str', str2: 'str', str: 'str' } }) }
  end

  context do
    let(:query) { '{ obj { x1: x, x2: x } }' }
    it { should eq({ data: { obj: { x1: 'x', x2: 'x' } } }) }
  end

  context do
    let(:query) { '{ arr { x1: x, x2: x } }' }
    it { should eq({ data: { arr: [{ x1: 'x', x2: 'x' }, { x1: 'x', x2: 'x' }] } }) }
  end
end
