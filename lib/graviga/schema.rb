module Graviga
  class Schema
    attr_accessor :query, :mutation, :namespace

    def initialize(query: :Query, mutation: :Mutation, namespace: Object)
      self.query = query
      self.mutation = mutation
      self.namespace = namespace
    end

    def execute(*args)
      Executor.new(self).execute(*args)
    end
  end
end
