require 'iso8601'

module Objectmancy
  # Namespace for storing type logic around manipulating different data types.
  module Types
    # DateTime special type specification
    DATETIME = {
      klass: ISO8601::DateTime,
      objectable: :new,
      hashable: :to_s
    }.freeze

    # Known types with special behavior defined.
    SPECIAL_TYPES = {
      datetime: DATETIME
    }.freeze
  end
end
