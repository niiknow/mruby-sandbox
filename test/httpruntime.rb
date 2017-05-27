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
  assert_equal " b", rst[:a]
  assert_equal "d", rst[:" c"]
end


assert('SANDBOX::HttpRuntime.qsencode') do
  t = SANDBOX::HttpRuntime. new
  data = {:a => " b", :" c" => "d" }
  rst = t.qsencode(data)
  assert_equal 'a=%20b&%20c=d', rst
end