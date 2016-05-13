require 'spec_helper'

describe 'union' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :x, :FooOrBar

        def x
          { type: :Foo }
        end
      end

      class FooOrBarType < Graviga::Types::UnionType
        types :Foo, :Bar

        def resolve_type(value)
          value[:type]
        end
      end

      class FooType < Graviga::Types::ObjectType
        field :y, :String

        def y
          'foo-y'
        end
      end

      class BarType < Graviga::Types::ObjectType
        field :y, :String

        def y
          'bar-y'
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
      {
        x {
          ... on Foo { y }
          ... on Bar { y }
        }
      }
      '
    end
    it { should eq({ data: { x: { y: 'foo-y' } } }) }
  end

  context do
    let(:query) do
      '
      {
        x {
          ...A
        }
      }
      fragment A on Bar { y }
      '
    end
    before do
      allow_any_instance_of(Sandbox::QueryType)
        .to receive(:x).and_return(type: :Bar)
    end

    it { should eq({ data: { x: { y: 'bar-y' } } }) }
  end
end
