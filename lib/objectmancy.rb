require 'objectmancy/objectable'

# Namespace for all Objectmancy functionality
# Also serves as a mixin to include Objectable
module Objectmancy
  def self.included(base)
    base.include(Objectable)
  end
end
