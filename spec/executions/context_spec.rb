require 'spec_helper'

describe 'context' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :echo, :String

        def echo
          context[:foo]
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:query) { '{ echo }' }

  subject { schema.execute(query, context: { foo: 'bar' }) }

  it { should eq({ data: { echo: 'bar' } }) }
end
