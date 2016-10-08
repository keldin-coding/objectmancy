require_relative '../../test_helper'

class ObjectableMassUpdateTest < Minitest::Test
  # Verifies attributes are updated.
  def test_updates_all_provided_attributes
    test_obj = ObjTestClasses::TestObject.new(name: 'old name')
    test_obj.mass_update(name: 'new', primes: [1, 2])

    assert_equal('new', test_obj.name)
    assert_equal([1, 2], test_obj.primes)
  end

  # Verifies unregistered attributes aren't updated and no new attributes are
  # created.
  def test_avoids_updating_unknown_attributes
    test_obj = ObjTestClasses::TestObject.new(book: {title: 'title'})
    test_obj.mass_update(higgilty_piggilty: 'something')

    refute_respond_to(test_obj, :higgilty_piggilty)
  end

  # Verifies that it follows all registrations
  def test_properly_calls_any_custom_methods
    test_obj = ObjTestClasses::TestObject.new(video_game: 'foobar/baffle')
    test_obj.mass_update(video_game: 'vibrant/smile')

    assert_equal('smile', test_obj.video_game.developer)
  end
end
