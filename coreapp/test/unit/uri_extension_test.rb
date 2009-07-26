require File.dirname(__FILE__) + '/../test_helper'

class URIExtensionTest < ActiveSupport::TestCase

  # See lib/uri_extension.rb for definitions of 'authority', 'base domain', and equivalent domains

  HOST = "outspokes.com"
  USERINFO = "arthur"
  PORT = 3000
  IP = "127.0.0.1"
  
  AUTHORITY = {
    :legal => {
      "just host" => HOST, 
      "userinfo with host" => "#{USERINFO}@#{HOST}", 
      "port with host" => "#{HOST}:#{PORT}", 
      "userinfo with host and port" => "#{USERINFO}@#{HOST}:#{PORT}"
    }, 
    :illegal => {
      "userinfo@ without host" => "#{USERINFO}@", 
      ":port without host" => ":#{PORT}", 
      "userinfo@ without host with :port" => "#{USERINFO}@:#{PORT}"
    }
  }
  
  BASE_URL = "http://" + AUTHORITY[:legal]["just host"]
  ILLEGAL_URL = "http://" + AUTHORITY[:illegal]["userinfo@ without host"]
  
  URL = { # all of the following are legal URLs
    "just authority" =>                             BASE_URL, 
    "authority with path" =>                        BASE_URL + "/accounts/7", 
    "authority with path and query" =>              BASE_URL + "/accounts/7?special=true", 
    "authority with path and longer query" =>       BASE_URL + "/accounts/7?special=true&also=false", 
    "authority with path and query and fragment" => BASE_URL + "/accounts/7?special=true#vabeach", 
    "authority with query" =>                       BASE_URL + "?special=true", 
    "authority with query and fragment" =>          BASE_URL + "?special=true#vabeach", 
    "authority with fragment" =>                    BASE_URL + "#vabeach", 
  }
  
  
  # authority tests
  
  test "authority ignores default port (port 80)" do
    got = URI.parse( "http://" + HOST + ":80" ).authority
    expected = HOST
    assert got == expected, "'authority' did not ignore port 80:\n got: #{got} but expected: #{expected}"
  end
  
  test "authority ignores blank port (:)" do
    got = URI.parse( "http://" + HOST + ":" ).authority
    expected = HOST
    assert got == expected, "'authority' did not ignore a blank port:\n got: #{got} but expected: #{expected}"
  end
  
  test "authority ignores the 'www' subdomain" do
    got = URI.parse( "http://" + "www." + HOST).authority
    expected = HOST
    assert got == expected, "'authority' did not ignore a blank port:\n got: #{got} but expected: #{expected}"
  end

  test "authority doesn't strip out 'www' from middle of domain" do
    expected = "foo-www.com"
    got = URI.parse( "http://foo-www.com").authority
    assert got == expected, "'authority' did not respect www in the middle of the url:\n got: #{got} but expected: #{expected}"
  end

  test "authority doesn't strip www-* domains" do
    expected = "www-1.google.com"
    got = URI.parse( "http://www-1.google.com").authority
    assert got == expected, "'authority' did not respect www-1 in the the url:\n got: #{got} but expected: #{expected}"
  end
  
  test "authority ignores blank userinfo (@)" do
    got = URI.parse( "http://" + "@" + HOST).authority
    expected = HOST
    assert got == expected, "'authority' did not ignore a blank port:\n got: #{got} but expected: #{expected}"
  end
  
  test "detects all legal authority cases" do
    AUTHORITY[:legal].each do |desc, authority|
      got = URI.parse( "http://" + authority ).authority
      expected = authority
      assert got == expected, "'authority' did not identify legal case '#{desc}':\n got: #{got} but expected: #{expected}"
    end
  end
  
  test "detects all legal authority cases with IP address for host" do
    AUTHORITY[:legal].each do |desc, authority|
      authority.sub Regexp.new(HOST), IP
      got = URI.parse( "http://" + authority ).authority
      expected = authority
      assert got == expected, "'authority' did not identify legal case '#{desc}':\n got: #{got} but expected: #{expected}"
    end
  end
  
  test "detects all illegal authority cases" do
    # This is ultimately testing that the URI module correctly parses urls, is just here for completeness
    AUTHORITY[:illegal].each do |desc, authority|
      assert_raises URI::InvalidURIError, "did not throw an exception for #{desc}: #{authority}" do
        URI.parse( "http://" + authority ).authority
      end
    end
  end
  
  
  # base domain tests
  
  test "should be able to convert any legal URL string to it's base domain" do
    URL.each do |desc, url|
      got = URI.base_domain(url)
      expected = BASE_URL
      assert got == expected, "'base_domain' did not convert a legal url case '#{desc}':\n got #{got} but expected #{expected}"
    end
  end
  
  test "base domain should return nil for invalid domains" do
    assert_nil URI.base_domain( ILLEGAL_URL ) # invalid authority
    assert_nil URI.base_domain( "asfdasfdasfasd" ) # no scheme
    assert_nil URI.base_domain( "0987098709870987" ) # no scheme
    assert_nil URI.base_domain( nil )
  end
  
  
  # same domain tests
  
  test "a domain should be equivalent to itself" do
    assert URI.same_domain?( BASE_URL, BASE_URL)
  end
  
  test "a domain should be equivalent to itself, regardless of case" do
    assert URI.same_domain?( BASE_URL.upcase, BASE_URL )
    assert URI.same_domain?( BASE_URL, BASE_URL.upcase )
    assert URI.same_domain?( BASE_URL.upcase, BASE_URL.upcase )
  end

  test "a domain with a trailing slash is equivalent to its base domain" do
    assert URI.same_domain?( BASE_URL + "/", BASE_URL )
  end
  
  URL.each do |desc, url|
    test "a domain with #{desc} is equivalent to its base domain" do
      assert URI.same_domain?( url, BASE_URL )
    end
  end
  
  test "domains that only differ by blank port should be equivalent" do
    assert URI.same_domain?( "http://google.com:", "http://google.com" )
  end
  
  test "domains that only differ by default port should be equivalent" do
    assert URI.same_domain?( "http://google.com:80", "http://google.com" )
  end
  
  test "domains that only differ by 'www.' should be equivalent" do
    assert URI.same_domain?( "http://www.google.com/", "http://google.com/" )
  end
  
  test "domains with different schemes shouldn't be equivalent" do
    assert ! URI.same_domain?( "https://mail.google.com/", "http://mail.google.com" )
  end
  
  test "domains with different subdomains shouldn't be equivalent" do
    assert ! URI.same_domain?( "http://mail.google.com/", "http://google.com/" )
  end
  
  test "domains with different hosts shouldn't be equivalent" do
    assert ! URI.same_domain?( "http://yahoo.com/", "http://google.com/" )
  end
  
  test "domains with different TLDs shouldn't be equivalent" do
    assert ! URI.same_domain?( "http://google.biz", "http://google.com" )
  end
  
  test "domains with different ports shouldn't be equivalent" do
    assert ! URI.same_domain?( "http://google.com:3000", "http://google.com:8080" )
  end
  
  test "an invalid domain shouldn't be equivalent to itself" do
    assert ! URI.same_domain?( "acbdefghijklmnopqrstuvwxyz", "acbdefghijklmnopqrstuvwxyz" )
  end
  
  test "nil domains shouldn't be equivalent to each other" do
    assert ! URI.same_domain?( nil, nil )
  end

end
