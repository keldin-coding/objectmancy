require 'objectmancy/errors'
require 'objectmancy/types'

require 'pry'

module Objectmancy
  # Mixin for allowing your objects to take a Hash and turn them into an object.
  # By default, the values will be whatever the value of the Hash at that key
  # is.
  # @example Including Objectable
  #   class Kitten
  #     include Objectmancy::Objectable
  #
  #     attribute :name
  #   end
  #
  #   tabby = Kitten.new(name: 'Eddy')
  #   tabby.name # => "Eddy"
  #
  #
  module Objectable
    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods mixed into anything including Objectable. These are where
    # the real power of Objectmancy comes from.
    module ClassMethods
      # @private
      # Basic setup of the class-level state.
      def self.extended(base)
        base.instance_variable_set(:@registered_attributes, {})
        base.class.send(:attr_reader, :registered_attributes)
        base.send(:private_class_method, :attribute)
      end

      # Defines an attribute usable by Objectmancy to create your object.
      # Only attributes defined with this method will be converted to attributes
      # on the final object.
      #
      # @param name [String, Symbol, #to_sym] Attribute name
      # @param opts [Hash] Optional attributes to be applied
      # @option opts [Symbol, Class] :type The type of object to create. Can be
      #   either a Symbol of one of: :datetime; else, a Class
      # @option opts [Symbol, String] :objectable Method to call on :type. Will
      #   default to calling :new. Ignored if :type is one of the known types.
      # @raise [AttributeAlreadyDefinedError] Attempt to define two attributes
      #   of the same name
      def attribute(name, **opts)
        symbolized_name = name.to_sym

        if registered_attributes.key? symbolized_name
          raise AttributeAlreadyDefinedError, name
        end

        registered_attributes[symbolized_name] = {
          type: opts[:type],
          objectable: opts[:objectable]
        }

        attr_accessor symbolized_name
      end
    end

    # Creates your object. You should use the after_initialize
    #
    # @param attrs [Hash] Hash of attributes to create the object with
    def initialize(attrs = {})
      _assignable_attributes(attrs).each do |attr, value|
        options = self.class.registered_attributes[attr.to_sym]

        if options[:type]
          value = _convert_value(value, options[:type], options[:objectable])
        end

        send("#{attr}=", value)
      end
    end

    private

    # Determines which attributes are assignable
    #
    # @param attrs [Hash] Provided base hash
    # @return [Hash] Allowed attributes
    def _assignable_attributes(attrs)
      attrs.select { |k, _| self.class.registered_attributes.include? k.to_sym }
    end

    # Handles object creation of arbitrary types
    #
    # @param old_value [Object] Value to be converted
    # @param type [Symbol, Class] Type of object to create
    # @param creator [#to_s, nil] Method used to create the object
    # @return [Object] The newly created object
    def _convert_value(old_value, type, creator)
      if (known = Types::SPECIAL_TYPES[type])
        known[:klass].send(known[:objectable], old_value)
      else
        type.send((creator || :new), old_value)
      end
    end
  end
end
