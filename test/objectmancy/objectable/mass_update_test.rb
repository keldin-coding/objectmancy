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
    test_obj = ObjTestClasses::TestObject.new(book: { title: 'title' })
    test_obj.mass_update(higgilty_piggilty: 'something')

    refute_respond_to(test_obj, :higgilty_piggilty)
  end

  # Verifies that it follows all registrations
  def test_properly_calls_any_custom_methods
    test_obj = ObjTestClasses::TestObject.new(video_game: 'foobar/baffle')
    test_obj.mass_update(video_game: 'vibrant/smile')

    assert_equal('smile', test_obj.video_game.developer)
  end

  def test_method_returns_self
    test_obj = ObjTestClasses::TestObject.new(name: 'old name')
    assert_same(test_obj, test_obj.mass_update(name: 'new', primes: [1, 2]))
  end

  def test_before_callback
    test_obj = ObjTestClasses::TestObject.new
    test_obj.mass_update(name: 'before')
    assert_equal(:before_update_set, test_obj.before_mass_update_set)
  end

  def test_after_callback
    test_obj = ObjTestClasses::TestObject.new
    test_obj.mass_update(name: 'after')
    assert_equal(:after_update_set, test_obj.after_mass_update_set)
  end
end
