#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'simple_barcode_scanner'
  s.version          = '0.1.7'
  s.summary          = 'simple_barcode_scanner that let you scan barcode and qr code in mobile, web and windows.'
  s.description      = <<-DESC
simple_barcode_scanner that let you scan barcode and qr code in mobile, web and windows.
                       DESC
  s.homepage         = 'https://github.com/CodingWithTashi/simple_barcode_scanner'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kunchok Tashi' => 'tashi@kharagedition.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{swift,h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.resources = 'Assets/*.png'
  s.dependency 'Flutter'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
end
