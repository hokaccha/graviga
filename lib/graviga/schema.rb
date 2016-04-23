module Graviga
  module Schema
    def self.included(klass)
      klass.extend ModuleMethods
      klass.include Graviga::Types
    end

    module ModuleMethods
      def execute(query)
        data = {}
        type = self::Query.new
        doc = GraphQL.parse(query)
        doc.definitions.each do |part|
          part.selections.each do |selection|
            name = selection.name
            data[selection.name.to_sym] = type.send(name)
          end
        end

        { data: data }
      end
    end
  end
end
