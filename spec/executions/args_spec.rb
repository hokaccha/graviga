require 'spec_helper'

describe 'hello world' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :echo, :String, args: { str: :String! }

        def echo(str:)
          str
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:result) { schema.execute(query) }

  context 'when str is string' do
    let(:query) { '{ echo(str: "foo") }' }
    it { expect(result).to eq({ data: { echo: 'foo' } }) }
  end

  context 'when returns int' do
    let(:query) { '{ echo(str: 1) }' }
    it { expect(result).to eq({ data: { echo: '1' } }) }
  end
end
