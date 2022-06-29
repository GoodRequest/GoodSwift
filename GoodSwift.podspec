Pod::Spec.new do |s|
  s.name             = 'GoodSwift'
  s.version          = '0.10.1'
  s.summary          = 'Some good swift extensions.'

  s.description      = <<-DESC
Some good swift extensions, handfully crafted by GoodRequest team.
                       DESC

  s.homepage         = 'https://github.com/GoodRequest/GoodSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Marek Spalek' => 'marek.spalek@goodrequest.com' }
  s.source           = { :git => 'https://github.com/GoodRequest/GoodSwift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/goodrequestcom'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.1'

  s.source_files = 'Sources/GoodSwift/*'
  s.frameworks = 'UIKit'
  s.dependency 'Alamofire', '~> 5.4'
  s.dependency 'Unbox', '~> 3.0'

end
