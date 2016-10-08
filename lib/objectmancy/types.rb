module Objectmancy
  # Namespace for storing type logic around manipulating different data types.
  module Types
    # Known types with special behavior defined.
    SPECIAL_TYPES = {
      datetime: { klass: Time, objectable: :iso8601 }
    }.freeze
  end
end
