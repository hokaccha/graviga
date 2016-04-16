require 'spec_helper'

describe Graviga do
  class PostType < Graviga::ObjectType
    field :id,       :id,    null: false
    field :title,    :string
    field :body,     :string
    # field :comments, [:comment]
  end

  class QueryType < Graviga::ObjectType
    field :post, PostType

    def post
      OpenStruct.new(id: '1', title: 'foo', body: 'bar')
    end
  end

  it 'has a version number' do
    expect(Graviga::VERSION).not_to be nil
  end

  specify do
    schema = Graviga::Schema.new(query: QueryType)
    result = schema.execute('query name { post { id, title } }')
    expect(result).to be_a Hash
    data = result['data']
    post = data['post']
    expect(post['id']).to eq '1'
    expect(post['title']).to eq 'foo'
  end
end
