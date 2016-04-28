require 'spec_helper'
require 'hashie'

describe 'PostSchema' do
  module PostSchema
    include Graviga::Schema

    class QueryType < ObjectType
      field :post, :Post!

      def post
        Hashie::Mash.new(
          id: '1',
          title: 'foo',
          body: 'bar',
          tags: ['t1', 't2'],
          comments: [
            { id: '1', text: 'a' },
            { id: '2', text: 'b' },
            { id: '3', text: 'c' },
          ]
        )
      end
    end

    class PostType < ObjectType
      field :id, :ID!
      field :title, :String!
      field :body, :String!
      field :tags, [:String]
      field :comments, [:Comment]

      def comments
        source.comments.first(2)
      end
    end

    class CommentType < ObjectType
      field :id, :ID!
      field :text, :String!
    end
  end

  specify do
    query = '
      {
        post {
          id,
          title,
          body,
          tags,
          comments {
            id, text
          }
        }
      }
    '
    result = PostSchema.execute(query)

    expect(result).to eq(
      data: {
        post: {
          id: '1',
          title: 'foo',
          body: 'bar',
          tags: ['t1', 't2']  ,
          comments: [
            { id: '1', text: 'a' },
            { id: '2', text: 'b' },
          ]
        }
      }
    )
  end
end
