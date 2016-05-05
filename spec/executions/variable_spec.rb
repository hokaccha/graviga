require 'spec_helper'

describe 'variable' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :echo, :String, args: { foo: :String }

        def echo(foo:)
          foo
        end
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }
  let(:query) { 'query q($x: String!) { echo(foo: $x) }' }

  subject { schema.execute(query, variables: { x: 'y' }) }

  it { should eq({ data: { echo: 'y' } }) }
end
