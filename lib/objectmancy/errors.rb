module Objectmancy
  # Error for defining attributes with the same name
  class AttributeAlreadyDefinedError < StandardError
    attr_reader :attribute

    # Creates a new AttributeAlreadyDefinedError
    #
    # @param [#to_s] Name of the attribute in error
    def initialize(attribute)
      @attribute = attribute
    end

    # Message for logging
    #
    # @return [String] message containing the attribute name
    # explaining the error.
    def message
      "#{attribute} has already been defined."
    end
  end
end
