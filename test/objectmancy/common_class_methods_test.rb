require_relative '../test_helper'

class CommonClassMethodsTest < Minitest::Test
  # Verifies that random attr_accessors are not defined.
  def test_does_not_create_attr_accessors_for_undefined_attributes
    assert_raises(NoMethodError) do
      ObjTestClasses::TestObject.new(cat: 'cat').cat
    end
  end

  # Verifies that an AttributeAlreadyDefinedError is raised for duplicate
  # attributes.
  def test_raises_attribute_already_defined_error_for_duplicates
    assert_raises(Objectmancy::AttributeAlreadyDefinedError) do
      ObjTestClasses::TestObject.send :attribute, :name
    end
  end

  # Verifies that an ArgumentError is raised when objectable is passed in
  # without type
  def test_raises_argument_error_with_objectable_and_without_type
    assert_raises(ArgumentError) do
      ObjTestClasses::TestObject.send :attribute,
                                      :something_else,
                                      objectable: :blurgh
    end
  end

  class ObjectableOnly
    include Objectmancy::Objectable
  end

  # Multiples require the type option when dealing with an Objectable class only
  def test_multiples_raises_argument_error_without_type_for_objectable_only
    assert_raises(ArgumentError) do
      ObjectableOnly.send(:multiples, :something)
    end
  end

  class HashableOnly
    include Objectmancy::Hashable
  end

  # Multiples do not require the type option when dealing with a Hashable class
  def test_multiples_does_not_require_type_for_hashable_only
    HashableOnly.send(:multiples, :something)

    obj = HashableOnly.new
    obj.something = [1, 2]

    assert_instance_of(Hash, obj.hashify)
  end
end
