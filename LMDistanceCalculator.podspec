Pod::Spec.new do |s|

s.name              = 'LMDistanceCalculator'
s.version           = '1.0.0'
s.summary           = 'LMDistanceCalculator is a simple wrapper for calculating geometry and real distance between locations on Earth.'
s.homepage          = 'https://github.com/lminhtm/LMDistanceCalculator'
s.platform          = :ios, '7.0'
s.license           = {
:type => 'MIT',
:file => 'LICENSE.txt'
}
s.author            = {
'LMinh' => 'lminhtm@gmail.com'
}
s.source            = {
:git => 'https://github.com/lminhtm/LMDistanceCalculator.git',
:tag => s.version.to_s
}
s.source_files      = 'LMDistanceCalculator/*.{m,h}'
s.requires_arc      = true

end