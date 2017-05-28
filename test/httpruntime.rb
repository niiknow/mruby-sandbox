def t_print(*args)
  i = 0
  len = args.size
  while i < len
    str = args[i].to_s
    __t_printstr__ str rescue print str
    i += 1
  end
end

assert('SANDBOX::HttpRuntime') do
  SANDBOX::HttpRuntime.class == Class
end

assert('SANDBOX::HttpRuntime.qsdecode') do
  t = SANDBOX::HttpRuntime. new
  rst = t.qsdecode('a=%20b&%20c=d')
  assert_equal " b", rst["a"]
  assert_equal "d", rst[" c"]
end

assert('SANDBOX::HttpRuntime.qsencode') do
  t = SANDBOX::HttpRuntime. new
  data = {"a" => " b", " c" => "d" }
  rst = t.qsencode(data)
  assert_equal "a=%20b&%20c=d", rst
end

assert('SANDBOX::HttpRuntime.request fail lookup') do
  CONSUMER_KEY        = ''
  CONSUMER_SECRET     = ''
  ACCESS_TOKEN        = ''
  ACCESS_TOKEN_SECRET = ''
  API_URL             = 'https://bogus.twitter.com/1.1/statuses/home_timeline.json'
  http = SANDBOX::HttpRuntime. new
  response = http.request({ "method" => "GET", "url" => API_URL, "auth" => {"oauth" => {"consumerkey" => CONSUMER_KEY, "consumersecret" => CONSUMER_SECRET, "accesstoken" => ACCESS_TOKEN, "tokensecret" => ACCESS_TOKEN_SECRET}}})

  assert_equal true, response["err"].message.include?("nodename")
end

assert('SANDBOX::HttpRuntime.request GET success') do
  API_URL             = 'https://www.google.com'
  http = SANDBOX::HttpRuntime. new
  response = http.request({ "method" => "GET", "url" => API_URL})

  assert_equal 200, response["statuscode"]
end