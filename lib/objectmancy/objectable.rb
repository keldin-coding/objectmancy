require 'objectmancy/errors'

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

    # Creates your object. You should use the after_initialize
    def initialize(hash = {})
      hash.select { |k, _| self.class.registered_attributes.include? k.to_sym }
          .each do |attr, value|
            send("#{attr}=", value)
          end
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
      # @raise [AttributeAlreadyDefinedError] Attempt to define two attributes
      #   of the same name
      def attribute(name, **opts)
        symbolized_name = name.to_sym

        if registered_attributes.key? symbolized_name
          raise AttributeAlreadyDefinedError, name
        end

        registered_attributes[symbolized_name] = {
          type: opts[:type]
        }

        attr_accessor symbolized_name
      end
    end
  end
end
