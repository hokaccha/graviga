module Graviga
  module Types
    class EnumType
      def self.value(name, value, options = {})
        @values ||= []
        @values << { name: name, value: value, options: options }
      end

      def self.values
        @values
      end

      def parse(name)
        return unless name
        v = self.class.values.find { |val| val[:name].to_sym == name.to_sym }
        v && v[:value]
      end

      def serialize(value)
        return unless value
        v = self.class.values.find { |val| val[:value] == value }
        v && v[:name].to_s
      end
    end
  end
end
