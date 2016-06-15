module Graviga
  class Schema
    attr_accessor :query, :mutation, :namespace

    def initialize(query: nil, mutation: nil, namespace: Object)
      self.query = query
      self.mutation = mutation
      self.namespace = namespace
    end

    def execute(*args)
      Executor.new(self).execute(*args)
    end

    def to_graphql
      SchemaPrinter.new(self).print_schema
    end
  end
end
