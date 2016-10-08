require_relative '../test_helper'

class ObjectableTest < Minitest::Test
  # Setup test classes
  class Book
    include Objectmancy::Objectable

    attribute :title
    attribute :author
  end

  class Cat
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class Game
    def initialize(title, developer)
      @title = title
      @developer = developer
    end

    def self.from_string(str)
      values = str.split '/'
      new(values.first, values.last)
    end
  end

  class TestObject
    include Objectmancy::Objectable

    attribute :name
    attribute :update_date, type: :datetime
    attribute :book, type: Book
    attribute :pet, type: Cat
    attribute :video_game, type: Game, objectable: :from_string
  end

  # Actual tests

  # Verifies that the attr_accessors are set up correctly
  def test_allows_assignment_of_raw_values
    name = 'smile'
    test_object = TestObject.new(name: name)

    assert_equal(name, test_object.name)
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

  # Verifies that DateTime types are parsed with DateTime
  def test_datetime_values_are_parsed
    update_date = '2015-12-01T16:43:35.878-05:00'
    test_object = TestObject.new(update_date: update_date)

    assert_instance_of(Time, test_object.update_date)
    assert_equal(Time.iso8601(update_date), test_object.update_date)
  end

  # Verifies that other Objectable objects are created
  def test_allows_other_objectable_types
    book_name = 'Simon Says'
    book_author = 'Violet Beauregard'
    test_object = TestObject.new(book: {
                                   title: book_name,
                                   author: book_author
                                 })

    assert_instance_of(Book, test_object.book)
  end

  # Verfies that objects responding to :new will correctly initialize.
  def test_non_objectable_types_with_default_new_method
    cat = 'Sophie'
    test_object = TestObject.new(pet: 'Sophie')

    assert_instance_of(Cat, test_object.pet)
  end

  # Verifies user-defined types with custom objectable method
  def test_user_defined_types_with_custom_objectable_method
    game = 'Land before time/Tri-ace'
    test_object = TestObject.new(video_game: game)

    assert_instance_of(Game, test_object.video_game)
  end
end
