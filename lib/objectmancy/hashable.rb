require 'objectmancy/common_class_methods'
require 'objectmancy/types'
require 'pry'

module Objectmancy
  # Mixin for allowing your object to be converted into a Hash.
  module Hashable
    # ClassMethods specific to Hashable functionality
    # module ClassMethods
    #   # Allows the definition of Arrays of items to be turns into objects. Bear
    #   # in mind that Arrays of basic objects (Strings, numbers, anything else
    #   # that doesn't need special initialization) are handled by .attribute.
    #   #
    #   # @param name [#to_sym] Attribute name
    #   # @param opts [Hash] Options to be applied
    #   # @option opts [Symbol, Class] :type The type of object to create. Can be
    #   #   either a Symbol of one of: :datetime; else, a Class
    #   # @option opts [Symbol, String] :objectable Method to call on :type. Will
    #   #   default to calling :new. Ignored if :type is one of the known types.
    #   # @raise [AttributeAlreadyDefinedError] Attempt to define two attributes
    #   #   of the same name
    #   def multiples(name, **opts)
    #     super(name, { hashable: true }.merge(opts))
    #   end
    # end

    # @private
    # This is a little shady, but I'm not sure of a better way to do it.
    # I gladly welcome suggestions.
    def self.included(base)
      base.extend(CommonClassMethods)
    end

    # Turns the object into a Hash according to the rules defined with
    #
    # @return [Hash] Hash representing the object
    def hashify
      _present_hashable_values.each_with_object({}) do |(attr, options), memo|
        memo[attr] = _hashify_value(send(attr), options)
      end
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
      if value.respond_to? :hashify
        value.hashify
      elsif attribute_options.multiple
        value.map { |v| _hashify_value(v, attribute_options.force_singular) }
      elsif attribute_options.hashable || attribute_options.type
        _convert_hashable_value(value, attribute_options)
      else
        value
      end
    end

    def _convert_hashable_value(value, attribute_options)
      hashable_method =
        attribute_options.hashable ||
        Types::SPECIAL_TYPES[attribute_options.type][:hashable]

      value.send(hashable_method)
    end
  end
end
