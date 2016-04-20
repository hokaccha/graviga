module BlogSchema
  include Graviga::Schema

  class Query < ObjectType
    field :articles, [:article]
  end

  class Mutation < ObjectType
  end

  class User < ObjectType
    field :id, :id!
    field :name, :string!
    field :activity, [:postable]
  end

  class Article < ObjectType
    implement :postable

    field :id, :id!
    field :title, :string!
    field :body, :string!
    field :user, :user!
    field :status, :status!
  end

  class Comment < ObjectType
    implement :postable

    field :id, :id!
    field :body, :string!
    field :user, :user!
  end

  class Postable < InterfaceType
    field :id, :id!
    field :user, :user!
  end

  class Status < EnumType
    value :draft, 0, description: 'draft'
    value :published, 1, description: 'published'
  end

  class ArticleInput < InputType
  end
end
