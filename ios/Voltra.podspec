require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'Voltra'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = 'Build dynamic iOS Live Activities and interact with the Dynamic Island directly from React Native. No Swift, no Xcode, no hassle.'
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = {
    :ios => '16.2',
  }
  s.swift_version  = '5.9'
  s.source         = { git: 'https://github.com/callstackincubator/voltra' }
  s.static_framework = true

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  # Default subspec: main app module (auto-linked by Expo)
  s.default_subspecs = 'Core'

  # Core subspec: React Native bridge module
  s.subspec 'Core' do |ss|
    ss.dependency 'ExpoModulesCore'
    ss.dependency 'Voltra/Shared'
    ss.dependency 'Voltra/UI'

    ss.source_files = [
      "app/**/*.swift",
    ]
  end

  # Widget subspec: Widget extension code
  s.subspec 'Widget' do |ss|
    ss.dependency 'Voltra/Shared'
    ss.dependency 'Voltra/UI'

    ss.source_files = [
      "target/**/*.swift", # Widget-specific files only
    ]
  end

  s.subspec 'UI' do |ss|
    ss.dependency 'Voltra/Shared'

    ss.source_files = [
      "ui/**/*.swift"
    ]
  end

  s.subspec 'Shared' do |ss|
    ss.source_files = [
      "shared/**/*.swift"
    ]
  end
end
