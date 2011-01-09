require File.join(File.dirname(__FILE__), "helper.rb")

class TestTrunkly < Test::Unit::TestCase

  def test_can_instantiate
    assert_not_nil Trunkly::Trunkly.new
  end
  
  def test_api_key_nil_if_not_initialized
    assert_nil Trunkly::Trunkly.new.api_key
  end
  
  def test_api_key_set_if_initialized
    assert_equal '12345', Trunkly::Trunkly.new('12345').api_key
  end
  
  # def test_get_public_links
  #   timslinks = Trunkly::Trunkly.new.links(:user => 'timbull')
  #   assert timslinks.size > 50
  # end
  
  def test_query_string
    t = Trunkly::Trunkly.new
    assert_equal "", t.send("query_string", {})
    
    params = {}
    params[:user] = 'a'
    assert_equal "", t.send("query_string", params)
    
    params = {}
    params[:one] = 1
    assert_equal "?one=1", t.send("query_string", params)
    
    params = {}
    params[:one] = 1
    params[:two] = 2
    assert_equal "?one=1&two=2", t.send("query_string", params)
    
    t.api_key = '12345'
    params = {}
    params[:one] = 1
    assert_equal "?one=1&api_key=12345", t.send("query_string", params)
  end
  
end
