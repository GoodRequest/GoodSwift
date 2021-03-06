Pod::Spec.new do |s|
  s.name             = 'GoodSwift'
  s.version          = '0.9.2'
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
  s.swift_version = '4.2'

  s.source_files = 'Source/*'
  s.frameworks = 'UIKit'
  s.dependency 'Alamofire', '~> 4.8'
  s.dependency 'Unbox', '~> 3.0'

end
