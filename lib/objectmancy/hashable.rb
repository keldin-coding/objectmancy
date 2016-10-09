require 'objectmancy/common_class_methods'
require 'objectmancy/types'
require 'pry'

module Objectmancy
  # Mixin for allowing your object to be converted into a Hash.
  module Hashable
    # @private
    def self.included(base)
      base.extend(CommonClassMethods)
    end

    # Turns the object into a Hash according to the rules defined with
    def hashify
      ary = _present_hashable_values.map do |attr, options|
        [attr, _hashify_value(send(attr), options)]
      end

      ary.to_h.reject { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
    end

    private

    # Provides current hashable values which have a non-empty value
    #
    # @return [Hash] Hash of values
    def _present_hashable_values
      self.class.registered_attributes.reject do |attr, _|
        attr_to_check = send(attr)

        attr_to_check.nil? ||
          (attr_to_check.respond_to?(:empty?) && attr_to_check.empty?)
      end
    end

    # Generates the value for the produced hash
    #
    # @param value [Object] Object to be used as a value for the hash
    # @param attribute_options [AttributeOptions] Options for the current
    #   attribute
    # @return [Object] Value for the final hash
    def _hashify_value(value, attribute_options)
      return value.hashify if value.respond_to?(:hashify)
      return value unless attribute_options.hashable || attribute_options.type

      _convert_hashable_value(value, attribute_options)
    end

    def _convert_hashable_value(value, attribute_options)
      hashable_method =
        attribute_options.hashable ||
          Types::SPECIAL_TYPES[attribute_options.type][:hashable]

      value.send(hashable_method)
    end
  end
end
