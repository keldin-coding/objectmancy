require_relative '../test_helper'

class ObjectableTest < Minitest::Test
  class TestObject
    include Objectmancy::Objectable

    attribute :name
  end

  # Verifies that the attr_accessors are set up correctly
  def test_allows_assignment_of_raw_values
    name = 'smile'

    assert_equal(name, TestObject.new(name: name).name)
  end

  # Verifies that random attr_accessors are not defined
  def test_does_not_create_attr_accessors_for_undefined_attributes
    assert_raises(NoMethodError) { TestObject.new(cat: 'cat').cat }
  end

  # Verifies that an AttributeAlreadyDefinedError is raised for duplicate
  # attributes
  def test_raises_attribute_already_defined_error_for_duplicates
    assert_raises(Objectmancy::AttributeAlreadyDefinedError) do
      TestObject.send :attribute, :name
    end
  end
end
