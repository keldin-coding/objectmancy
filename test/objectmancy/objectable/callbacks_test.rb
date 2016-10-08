require_relative '../../test_helper'

class ObjectableCallbacksTest < Minitest::Test
  def test_calls_before_initialize
    t = ObjTestClasses::TestObject.new

    assert_equal(:before_set, t.before_init)
  end

  def test_calls_after_initialize
    t = ObjTestClasses::TestObject.new

    assert_equal(:after_set, t.after_init)
  end
end
