require_relative '../test_helper'

class ObjectableTest < Minitest::Test
  # Setup test classes
  class Book
    include Objectmancy::Objectable

    attribute :title
    attribute :author

    def ==(other)
      self.class == other.class &&
        title == other.title &&
        author == other.author
    end
  end

  class Cat
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def ==(other)
      self.class == other.class &&
        name == other.name
    end
  end

  class Game
    attr_reader :title, :developer

    def initialize(title, developer)
      @title = title
      @developer = developer
    end

    def self.from_string(str)
      values = str.split '/'
      new(values.first, values.last)
    end

    def ==(other)
      self.class == other.class &&
        title == other.title &&
        developer == other.developer
    end
  end

  class TestObject
    include Objectmancy::Objectable

    attribute :name

    attribute :update_date, type: :datetime
    attribute :book, type: Book
    attribute :pet, type: Cat
    attribute :video_game, type: Game, objectable: :from_string
    attribute :primes

    multiples :birth_dates, type: :datetime
    multiples :library, type: Book
    multiples :menagerie, type: Cat
    multiples :board_games, type: Game, objectable: :from_string
  end

  # Actual tests

  # Verifies that the attr_accessors are set up correctly.
  def test_allows_assignment_of_raw_values
    name = 'smile'
    test_object = TestObject.new(name: name)

    assert_equal(name, test_object.name)
  end

  # Verifies that random attr_accessors are not defined.
  def test_does_not_create_attr_accessors_for_undefined_attributes
    assert_raises(NoMethodError) { TestObject.new(cat: 'cat').cat }
  end

  # Verifies that an AttributeAlreadyDefinedError is raised for duplicate
  # attributes.
  def test_raises_attribute_already_defined_error_for_duplicates
    assert_raises(Objectmancy::AttributeAlreadyDefinedError) do
      TestObject.send :attribute, :name
    end
  end

  # Verifies that an ArgumentError is raised when objectable is passed in
  # without type
  def test_raises_argument_error_with_objectable_and_without_type
    assert_raises(ArgumentError) do
      TestObject.send :attribute, :something_else, objectable: :blurgh
    end
  end

  # Verifies that DateTime types are parsed with ISO8601.
  def test_datetime_values_are_parsed
    update_date = '2015-12-01T16:43:35.878-05:00'
    test_object = TestObject.new(update_date: update_date)

    assert_instance_of(ISO8601::DateTime, test_object.update_date)
    assert_equal(ISO8601::DateTime.new(update_date), test_object.update_date)
  end

  # Verifies that other Objectable objects are created.
  def test_allows_other_objectable_types
    book_name = 'Simon Says'
    book_author = 'Violet Beauregard'
    test_object = TestObject.new(book: {
                                   title: book_name,
                                   author: book_author
                                 })

    assert_instance_of(Book, test_object.book)
    assert_equal(
      Book.new(title: book_name, author: book_author),
      test_object.book
    )
  end

  # Verfies that objects responding to :new will correctly initialize.
  def test_non_objectable_types_with_default_new_method
    cat = 'Sophie'
    test_object = TestObject.new(pet: 'Sophie')

    assert_instance_of(Cat, test_object.pet)
    assert_equal(Cat.new(cat), test_object.pet)
  end

  # Verifies user-defined types with custom objectable method.
  def test_user_defined_types_with_custom_objectable_method
    game = 'Land before time/Tri-ace'
    test_object = TestObject.new(video_game: game)

    assert_instance_of(Game, test_object.video_game)
    assert_equal(Game.from_string(game), test_object.video_game)
  end

  # Verifies arrays are unchanged
  def test_arrays_unchanged
    primes = [1, 2, 3, 5, 7, 11]
    test_object = TestObject.new(primes: primes)

    assert_instance_of(Array, test_object.primes)
    assert_equal(primes, test_object.primes)
  end

  # Multiples require the type option
  def test_multiples_require_type_option
    assert_raises(ArgumentError) do
      TestObject.send(:multiples, :something)
    end
  end

  # Verifies multiple datetimes can be parsed correctly.
  def test_multiples_of_datetimes
    birth_dates = %w(2012-01-14 1995-07-04)
    test_object = TestObject.new(birth_dates: birth_dates)

    test_object.birth_dates.each do |parsed_date|
      assert_instance_of(ISO8601::DateTime, parsed_date)
    end

    birth_dates.each do |birth_date|
      assert_includes(
        test_object.birth_dates,
        ISO8601::DateTime.new(birth_date)
      )
    end
  end

  # Verifies multiples of Objectable objects will work
  def test_multiples_of_other_objectable_types
    book_1 = { title: 'Foobar', author: 'Mr. Foobar' }
    book_2 = { title: 'Fiizbang', author: 'Miss Fizzbang' }
    books = [book_1, book_2]
    test_object = TestObject.new(library: books)

    test_object.library.each do |library_book|
      assert_instance_of(Book, library_book)
    end

    books.each do |book|
      assert_includes(test_object.library, Book.new(book))
    end
  end

  # Verfies that multiples of objects responding to :new will correctly
  # initialize.
  def test_non_objectable_types_with_default_new_method
    cat_1 = 'Amelia'
    cat_2 = 'Gorbypuff'
    cats = [cat_1, cat_2]
    test_object = TestObject.new(menagerie: cats)

    test_object.menagerie.each do |animal|
      assert_instance_of(Cat, animal)
    end

    cats.each do |cat|
      assert_includes(test_object.menagerie, Cat.new(cat))
    end
  end

  # Verifies user-defined types of multiples with custom objectable method.
  def test_user_defined_types_of_multiples_with_custom_objectable_method
    game_1 = 'Typical gamer/Tha Best'
    game_2 = 'Impossible dreams/Save it for later'
    games = [game_1, game_2]

    test_object = TestObject.new(board_games: games)

    test_object.board_games.each do |board_game|
      assert_instance_of(Game, board_game)
    end

    games.each do |game|
      assert_includes(test_object.board_games, Game.from_string(game))
    end
  end
end
