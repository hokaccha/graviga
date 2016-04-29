require 'spec_helper'
require 'hashie'

describe 'PostSchema' do
  before do
    module Sandbox
      class QueryType < Graviga::Types::ObjectType
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

      class PostType < Graviga::Types::ObjectType
        field :id, :ID!
        field :title, :String!
        field :body, :String!
        field :tags, [:String]
        field :comments, [:Comment]

        def comments
          source.comments.first(2)
        end
      end

      class CommentType < Graviga::Types::ObjectType
        field :id, :ID!
        field :text, :String!
      end
    end
  end

  let(:schema) { Graviga::Schema.new(query: :Query, namespace: Sandbox) }

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
    result = schema.execute(query)

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
