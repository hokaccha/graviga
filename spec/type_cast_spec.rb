require 'spec_helper'

describe 'type cast' do
  module TypeCastSchema
    include Graviga::Schema

    class QueryType < ObjectType
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

  specify do
    result = TypeCastSchema.execute('{ id, str, int, float, bool }')
    data = result[:data]
    expect(data[:id]).to eq '1'
    expect(data[:str]).to eq '2'
    expect(data[:int]).to eq 1
    expect(data[:float]).to eq 2.5
    expect(data[:bool]).to eq true
  end
end
