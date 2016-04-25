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

      def id(_)
        1
      end

      def str(_)
        2
      end

      def int(_)
        '1'
      end

      def float(_)
        '2.5'
      end

      def bool(_)
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
