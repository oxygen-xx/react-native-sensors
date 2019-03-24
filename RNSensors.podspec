Pod::Spec.new do |s|
  s.name                = 'RNSensors'
  s.version             = "2.4.2"
  s.summary             = "A developer friendly approach for sensors in react-native"
  s.description         = "A developer friendly approach for sensors in react-native"
  s.homepage            = "https://github.com/react-native-sensors/react-native-sensors.git"
  s.license             = "MIT"
  s.author              = "Daniel Schmidt"
  s.source              = { :git => "https://github.com/oxygen-xx/react-native-sensors.git" }
  s.platform            = :ios, "7.0"
  s.source_files        = "ios/*.{h,m}"
  s.preserve_paths      = "*.js"
  s.dependency 'React'
end
