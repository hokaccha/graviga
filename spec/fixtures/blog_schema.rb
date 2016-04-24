module BlogSchema
  include Graviga::Schema

  class QueryType < ObjectType
    field :articles, [:article]
    field :article, :article, args: { id: :int! }
    # field :article, :article, {
    #   description: 'foo',
    #   args: {
    #     id: { type: :int!, description: 'foo', default: 1 }
    #   }
    # }

    def article(arguments)
      Article.find(arguments[:id])
    end
  end

  class MutationType < ObjectType
  end

  class UserType < ObjectType
    field :id, :id!
    field :name, :string!
    field :activity, [:postable]
  end

  class ArticleType < ObjectType
    implement :postable

    field :id, :id!
    field :title, :string!
    field :body, :string!
    field :user, :user!
    field :status, :status!
  end

  class CommentType < ObjectType
    implement :postable

    field :id, :id!
    field :body, :string!
    field :user, :user!
  end

  class PostableType < InterfaceType
    field :id, :id!
    field :user, :user!
  end

  class StatusType < EnumType
    value :draft, 0, description: 'draft'
    value :published, 1, description: 'published'
  end

  class ArticleInputType < InputType
  end
end
