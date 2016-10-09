require_relative '../../test_helper'

# rubocop:disable Metrics/MethodLength
class ObjectableMultiplesTest < Minitest::Test
  # Verifies multiple datetimes can be parsed correctly.
  def test_multiples_of_datetimes
    birth_dates = %w(2012-01-14 1995-07-04)
    test_object = ObjTestClasses::TestObject.new(birth_dates: birth_dates)

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
    book1 = { title: 'Foobar', author: 'Mr. Foobar' }
    book2 = { title: 'Fiizbang', author: 'Miss Fizzbang' }
    books = [book1, book2]
    test_object = ObjTestClasses::TestObject.new(library: books)

    test_object.library.each do |library_book|
      assert_instance_of(ObjTestClasses::Book, library_book)
    end

    books.each do |book|
      assert_includes(test_object.library, ObjTestClasses::Book.new(book))
    end
  end

  # Verfies that multiples of objects responding to :new will correctly
  # initialize.
  def test_multiples_non_objectable_types_with_default_new_method
    cat1 = 'Amelia'
    cat2 = 'Gorbypuff'
    cats = [cat1, cat2]
    test_object = ObjTestClasses::TestObject.new(menagerie: cats)

    test_object.menagerie.each do |animal|
      assert_instance_of(ObjTestClasses::Cat, animal)
    end

    cats.each do |cat|
      assert_includes(test_object.menagerie, ObjTestClasses::Cat.new(cat))
    end
  end

  # Verifies user-defined types of multiples with custom objectable method.
  def test_multiples_user_defined_types_of_with_custom_objectable_method
    game1 = 'Typical gamer/Tha Best'
    game2 = 'Impossible dreams/Save it for later'
    games = [game1, game2]

    test_object = ObjTestClasses::TestObject.new(board_games: games)

    test_object.board_games.each do |board_game|
      assert_instance_of(ObjTestClasses::Game, board_game)
    end

    games.each do |game|
      assert_includes(
        test_object.board_games,
        ObjTestClasses::Game.from_string(game)
      )
    end
  end
end
# rubocop:enable Metrics/MethodLength
