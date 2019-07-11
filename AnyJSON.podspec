Pod::Spec.new do |s|
  s.name     = 'AnyJSON'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.summary  = 'Encode / Decode JSON by any means possible.'
  s.homepage = 'https://github.com/mattt/AnyJSON'
  s.authors  = { 'Mattt' => 'mattt@me.com', 'Cédric Luthi' => 'cedric.luthi@gmail.com' }
  s.source   = { git: 'https://github.com/mattt/AnyJSON.git', tag: s.version }
  s.source_files = 'AnyJSON'
end
