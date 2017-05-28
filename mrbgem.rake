MRuby::Gem::Specification.new('mruby-sandbox') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Tom Noogen'
  spec.version = '0.0.1'


  spec.add_dependency 'mruby-array-ext',   core: 'mruby-array-ext'
  spec.add_dependency 'mruby-exit',        core: 'mruby-exit'
  spec.add_dependency 'mruby-hash-ext',    core: 'mruby-hash-ext'
  spec.add_dependency 'mruby-proc-ext',    core: 'mruby-proc-ext'
  spec.add_dependency 'mruby-string-ext',  core: 'mruby-string-ext'

  spec.add_dependency('mruby-regexp-pcre', :github => 'nsheremet/mruby-regexp-pcre')
  spec.add_dependency('mruby-pack')
  spec.add_dependency('mruby-digest')
  spec.add_dependency('mruby-json')
  spec.add_dependency('mruby-sleep')
  spec.add_dependency('mruby-http')
  spec.add_dependency('mruby-httprequest')

  spec.add_test_dependency('mruby-regexp-pcre', :github => 'nsheremet/mruby-regexp-pcre')
  spec.add_test_dependency('mruby-mtest')
end
