require 'objectmancy/common_class_methods'
require 'objectmancy/types'

module Objectmancy
  # Mixin for allowing your object to be converted into a Hash.
  module Hashable
    # @private
    def self.included(base)
      base.extend(CommonClassMethods)
    end

    # Turns the object into a Hash according to the rules defined with
    def hashify
      ary = self.class.registered_attributes.map do |attr, options|
        [attr, _hashify_value(send(attr), options)]
      end
      ary.to_h.reject { |_, v| v.nil? }
    end

    private

    # Generates the value for the produced hash
    #
    # @param value [Object] Object to be used as a value for the hash
    # @param attribute_options [AttributeOptions] Options for the current
    #   attribute
    # @return [Object] Value for the final hash
    def _hashify_value(value, attribute_options)
      value.respond_to?(:hashify) ? value.hashify : value
    end
  end
end
