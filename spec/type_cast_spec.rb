require 'spec_helper'

describe 'type cast' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :id, :ID
        field :str, :String
        field :int, :Int
        field :float, :Float
        field :bool, :Boolean

        def id
          1
        end

        def str
          2
        end

        def int
          '1'
        end

        def float
          '2.5'
        end

        def bool
          1
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

  specify do
    result = schema.execute('{ id, str, int, float, bool }')
    data = result[:data]
    expect(data[:id]).to eq '1'
    expect(data[:str]).to eq '2'
    expect(data[:int]).to eq 1
    expect(data[:float]).to eq 2.5
    expect(data[:bool]).to eq true
  end
end
