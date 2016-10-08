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

        if opts[:objectable] && (opts[:type].nil?)
          raise ArgumentError, ':objectable option reuqires :type option'
        end

        registered_attributes[symbolized_name] = {
          type: opts[:type],
          objectable: opts[:objectable],
          multiple: opts[:multiple]
        }

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

    # Creates your object. You should use the after_initialize
    #
    # @param attrs [Hash] Hash of attributes to create the object with
    def initialize(attrs = {})
      _assignable_attributes(attrs).each do |attr, value|
        options = self.class.registered_attributes[attr.to_sym]

        if options[:multiple]
          value = _convert_multiples(
            value, options[:type], options[:objectable]
          )
        elsif options[:type]
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

    # Assigns a multiples attribute
    #
    # @param multiples [Array] Array of values to be converted
    # @param type [Symbol, Class] Type of object to create
    # @param creator [#to_s, nil] Method used to create the object
    # @return [Array] Array of newly created objects
    def _convert_multiples(multiples, type, creator)
      if (known = Types::SPECIAL_TYPES[type])
        creation_klass, creation_method = known[:klass], known[:objectable]
      else
        creation_klass = type
        creation_method = creator || :new
      end

      multiples.map { |m| creation_klass.send(creation_method, m) }
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
