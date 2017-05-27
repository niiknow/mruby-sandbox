MRuby::Gem::Specification.new('mruby-sandbox') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Tom Noogen'
  spec.version = '0.0.1'

  spec.add_dependency('mruby-pack')
  spec.add_dependency('mruby-digest')
  spec.add_dependency('mruby-json')
  spec.add_dependency('mruby-sleep')
  spec.add_dependency('mruby-http')
  spec.add_dependency('mruby-httprequest')
end
