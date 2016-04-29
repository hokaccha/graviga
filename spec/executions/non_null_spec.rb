require 'spec_helper'

describe 'non null' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
        field :scalar, :String!
        field :object, :Obj!
        field :list1, :'[String!]'
        field :list2, :'[String]!'
        field :list3, :'[String!]!'
      end

      class ObjType < Graviga::Types::ObjectType
      end
    end
  end

  after { Object.send(:remove_const, :Sandbox) }

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

  matcher :be_ok do
    match { |actual| actual[:errors].nil? }
  end

  matcher :be_error_with do |expected|
    match do |actual|
      error = actual[:errors].first
      expect(error).to be_a Graviga::ExecutionError
      expect(error.message).to be_include expected
    end
  end

  def stub_query_method(method, value)
    allow_any_instance_of(Sandbox::QueryType).to receive(method).and_return(value)
  end

  subject { schema.execute(query) }

  describe 'String!' do
    let(:query) { '{ scalar }' }

    context 'when method is not defined' do
      it { should be_error_with('QueryType.scalar') }
    end

    context 'when return nil' do
      before { stub_query_method(:scalar, nil) }
      it { should be_error_with('QueryType.scalar') }
    end

    context 'when return non nil' do
      before { stub_query_method(:scalar, 'x') }
      it { should be_ok }
    end
  end

  describe '[String!]' do
    let(:query) { '{ list1 }' }
    before { stub_query_method(:list1, return_value) }

    context 'when return []' do
      let(:return_value) { [] }
      it { should be_ok }
    end

    context 'when return nil' do
      let(:return_value) { nil }
      it { should be_ok }
    end

    context 'when return [nil]' do
      let(:return_value) { [nil] }
      it { should be_error_with('QueryType.list1') }
    end
  end

  describe '[String]!' do
    let(:query) { '{ list2 }' }
    before { stub_query_method(:list2, return_value) }

    context 'when return []' do
      let(:return_value) { [] }
      it { should be_ok }
    end

    context 'when return nil' do
      let(:return_value) { nil }
      it { should be_error_with('QueryType.list2') }
    end

    context 'when return [nil]' do
      let(:return_value) { [nil] }
      it { should be_ok }
    end
  end

  describe '[String!]!' do
    let(:query) { '{ list3 }' }
    before { stub_query_method(:list3, return_value) }

    context 'when return []' do
      let(:return_value) { [] }
      it { should be_ok }
    end

    context 'when return nil' do
      let(:return_value) { nil }
      it { should be_error_with('QueryType.list3') }
    end

    context 'when return [nil]' do
      let(:return_value) { [nil] }
      it { should be_error_with('QueryType.list3') }
    end
  end
end
