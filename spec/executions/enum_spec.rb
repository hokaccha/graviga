require 'spec_helper'

describe 'enum' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :color, :Color, {
          args: {
            from_enum: :Color,
            from_int: :Int,
            from_string: :String,
          }
        }

        def color(args)
          if args[:from_enum]
            return args[:from_enum]
          end

          if args[:from_int]
            return args[:from_int]
          end

          if args[:from_string]
            return args[:from_string]
          end
        end
      end

      class ColorType < Graviga::Types::EnumType
        value :red, 0
        value :green, 1
        value :blue, 'blue!'
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

  subject { schema.execute(query) }

  context do
    let(:query) { '{ color(from_enum: green) }' }
    it { should eq({ data: { color: 'green' } }) }
  end

  context do
    let(:query) { '{ color(from_int: 1) }' }
    it { should eq({ data: { color: 'green' } }) }
  end

  context do
    let(:query) { '{ color(from_string: "green") }' }
    it { should eq({ data: { color: nil } }) }
  end

  context do
    let(:query) { '{ color(from_string: "blue!") }' }
    it { should eq({ data: { color: 'blue' } }) }
  end
end
