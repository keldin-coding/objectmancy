require_relative  '../../test_helper'

class HashableTest < Minitest::Test
  class Person
    include Objectmancy::Hashable

    attribute :first_name
    attribute :last_name

    def initialize(first_name, last_name)
      @first_name = first_name
      @last_name = last_name
    end
  end

  class NewTest
    include Objectmancy::Hashable

    attribute :name
    attribute :age
    attribute :person, type: Person
  end

  # Verifies regular values are hashified appropriately
  def test_hashify_regular_values
    test_obj = NewTest.new
    test_obj.name = 'sally'
    test_obj.age = 5
    generated_hash = test_obj.hashify

    assert_equal('sally', generated_hash[:name])
    assert_equal(5, generated_hash[:age])
  end

  # Verifies that Hashable objects are appropriately hashified.
  def test_hashify_class_with_hashable
    test_obj = NewTest.new
    person = Person.new('Edgar', 'Friendly')
    test_obj.person = person
    generated_hash = test_obj.hashify

    assert_equal(
      { person: { first_name: 'Edgar', last_name: 'Friendly' } },
      generated_hash
    )
  end
end
