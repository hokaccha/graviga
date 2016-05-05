module Graviga
  module Types
    BUILT_IN_TYPES = %w(ID String Int Float Boolean)

    module_function

    def built_in?(name)
      BUILT_IN_TYPES.include?(name.to_s)
    end
  end
end

require 'graviga/types/scalar_type'
require 'graviga/types/id_type'
require 'graviga/types/string_type'
require 'graviga/types/int_type'
require 'graviga/types/float_type'
require 'graviga/types/boolean_type'
require 'graviga/types/object_type'
require 'graviga/types/interface_type'
require 'graviga/types/enum_type'
require 'graviga/types/union_type'
require 'graviga/types/input_object_type'
