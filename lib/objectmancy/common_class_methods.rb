require 'objectmancy/errors'
require 'objectmancy/attribute_options'

module Objectmancy
   # Class methods mixed into anything including one of the mixins for
   # Objectmancy
  module CommonClassMethods
    # @private
    # Basic setup of the class-level state.
    def self.extended(base)
      base.instance_variable_set(:@registered_attributes, {})
      base.class.send(:attr_reader, :registered_attributes)
      base.send(:private_class_method, :attribute, :multiples)
    end

    # Defines an attribute usable by Objectmancy to create your object.
    # Only attributes defined with this method will be converted to attributes
    # on the final object.
    #
    # @param name [#to_sym] Attribute name
    # @param opts [Hash] Options to be applied
    # @option opts [Symbol, Class] :type The type of object to create. Can be
    #   either a Symbol of one of: :datetime; else, a Class
    # @option opts [Symbol, String] :objectable Method to call on :type. Will
    #   default to calling :new. Ignored if :type is one of the known types.
    #   Requires :type option.
    # @raise [AttributeAlreadyDefinedError] Attempt to define two attributes
    #   of the same name
    # @raise [ArgumentError] Pass in :objectable without :type
    def attribute(name, **opts)
      symbolized_name = name.to_sym

      if registered_attributes.key? symbolized_name
        raise AttributeAlreadyDefinedError, name
      end

      if opts[:objectable] && opts[:type].nil?
        raise ArgumentError, ':objectable option reuqires :type option'
      end

      registered_attributes[symbolized_name] = AttributeOptions.new(opts)

      attr_accessor symbolized_name
    end

    # Allows the definition of Arrays of items to be turns into objects. Bear
    # in mind that Arrays of basic objects (Strings, numbers, anything else
    # that doesn't need special initialization) are handled by .attribute.
    #
    # @param name [#to_sym] Attribute name
    # @param opts [Hash] Options to be applied
    # @option opts [Symbol, Class] :type The type of object to create. Can be
    #   either a Symbol of one of: :datetime; else, a Class
    # @option opts [Symbol, String] :objectable Method to call on :type. Will
    #   default to calling :new. Ignored if :type is one of the known types.
    # @raise [AttributeAlreadyDefinedError] Attempt to define two attributes
    #   of the same name
    # @raise [ArgumentError] Calling .multiples without :type option
    def multiples(name, **opts)
      if opts[:type].nil?
        raise ArgumentError, 'Multiples require the :type option'
      end

      attribute(name, opts.merge(multiple: true))
    end
  end
end
