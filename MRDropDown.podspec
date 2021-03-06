#
# Be sure to run `pod lib lint MRDropDown.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MRDropDown'
  s.version          = '0.1.1'
  s.summary          = 'Drop down list for Google places API'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    This is drop down list for google places API or any other data
                       DESC

  s.homepage         = 'https://github.com/mikeRozen/MRDropDown'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Micahel Rozenbalt' => 'mike.rozen1@gmail.com' }
  s.source           = { :git => 'https://github.com/mikeRozen/MRDropDown.git', :tag => '0.1.1' } #s.version.to_s
  s.swift_version = '3.3'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MRDropDown/**/*'
  
  # s.resource_bundles = {
  #   'MRDropDown' => ['MRDropDown/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
