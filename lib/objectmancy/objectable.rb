require 'objectmancy/common_class_methods'
require 'objectmancy/types'

module Objectmancy
  # Mixin for allowing your objects to take a Hash and turn them into an object.
  #
  # @example Including Objectable
  #   class Kitten
  #     include Objectmancy::Objectable
  #
  #     attribute :name
  #   end
  #
  #   tabby = Kitten.new(name: 'Eddy')
  #   tabby.name # => "Eddy"
  module Objectable
    # @private
    def self.included(base)
      base.extend(CommonClassMethods)
    end

    # Creates your object. You should use the after_initialize
    #
    # @param attrs [Hash] Hash of attributes to create the object with
    def initialize(attrs = {})
      before_initialize

      _attributes_update!(attrs)

      after_initialize
    end

    # Updates the attributes of the object
    #
    # @param attrs [Hash] Attributes to update
    def mass_update(attrs = {})
      tap do
        _attributes_update!(attrs)
      end
    end

    # Comparator for two objects
    #
    # @param other [Object]to be compared to
    # @return [TrueClass, FalseClass] Boolean indicating if the two objects
    #   are equal.
    def ==(other)
      self.class == other.class &&
        self.class.registered_attributes.keys.all? do |attr|
          send(attr) == other.send(attr)
        end
    end

    private

    # Empty before_initialize callback
    def before_initialize; end

    # Empty after_initialize callback
    def after_initialize; end

    # Determines which attributes are assignable
    #
    # @param attrs [Hash] Provided hash of attributes
    # @return [Hash] Allowed attributes
    def _assignable_attributes(attrs)
      attrs.select { |k, _| self.class.registered_attributes.include? k.to_sym }
    end

    # Updates the values for defiend attributes
    #
    # @param attrs [Hash] Provided hash of attributes
    def _attributes_update!(attrs)
      _assignable_attributes(attrs).each do |attr, value|
        options = self.class.registered_attributes[attr.to_sym]

        value =
          if options.multiple
            _convert_multiples(value, options.type, options.objectable)
          else
            _single_value(value, options)
          end

        send("#{attr}=", value)
      end
    end

    # Assigns a multiples attribute
    #
    # @param multiples [Array] Array of values to be converted
    # @param type [Symbol, Class] Type of object to create
    # @param creator [#to_s, nil] Method used to create the object
    # @return [Array] Array of newly created objects
    def _convert_multiples(multiples, type, creator)
      creation_klass, creation_method = _creation_method(type, creator)

      multiples.map { |m| creation_klass.send(creation_method, m) }
    end

    # Evaluates what needs to be done for a singular value.
    #
    # @param value [Object] Value to be assigned/evaluated.
    # @param options [AttributeOptions] Options pertaining to the attribute
    # @return [Object] Value for the new object
    def _single_value(value, options)
      return value unless options.type

      _convert_value(value, options.type, options.objectable)
    end

    # Handles object creation of arbitrary types
    #
    # @param old_value [Object] Value to be converted
    # @param type [Symbol, Class] Type of object to create
    # @param creator [#to_s, nil] Method used to create the object
    # @return [Object] The newly created object
    def _convert_value(old_value, type, creator)
      creation_klass, creation_method = _creation_method(type, creator)

      creation_klass.send(creation_method, old_value)
    end

    # Determines the method of creation for a custom object
    #
    # @param type [Symbol, Class] Type of object to create
    # @param creator [#to_s, nil] Method used to create the object
    # @return [Array] Class to create, method to call.
    def _creation_method(type, creator)
      if (known = Types::SPECIAL_TYPES[type])
        [known[:klass], known[:objectable]]
      else
        [type, (creator || :new)]
      end
    end
  end
end
