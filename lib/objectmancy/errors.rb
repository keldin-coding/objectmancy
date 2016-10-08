module Objectmancy
  # Error for defining attributes with the same name
  class AttributeAlreadyDefinedError < StandardError
    attr_reader :attribute

    # Creates a new AttributeAlreadyDefinedError
    #
    # @param attribute [#to_s] name of the attribute in error
    def initialize(attribute)
      @attribute = attribute
    end

    # Message for logging
    #
    # @return [String] message containing the attribute name
    #   explaining the error.
    def message
      "#{attribute} has already been defined."
    end
  end
end
