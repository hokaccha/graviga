module BlogSchema
  include Graviga::Schema

  class Query < ObjectType
    field :article, [:article!]
  end

  class Mutation < ObjectType
  end

  class User < ObjectType
    field :article, [:article!]
    field :post, [:post]
  end

  class Article < ObjectType
    implement :postable

    field :title, :string!
    field :body, :string!
    field :user, :user!
  end

  class Comment < ObjectType
    implement :postable

    field :body, :string!
    field :user, :user!
  end

  class Postable < InterfaceType
    field :user, :user!
  end

  class Post < UnionType
    type :article, :comment
  end

  class Category < EnumType
    value :FOO, 1, description: 'Foo category'
    value :BAR, 2, description: 'Bar category'
    value :BAZ, 3, description: 'Baz category'
  end

  class PostInput < InputType
  end
end
