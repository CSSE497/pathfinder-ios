Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name = 'thepathfinder'
  s.summary = 'Pathfinder makes routing easy.'
  s.requires_arc = true

  s.version = '0.0.1.1'

  s.description = 'Pathfinder is a routing service that removes the ' \
                  'complexities of logistics handling from your app.'

  s.license = { :type => 'MIT', :file => 'LICENSE' }

  s.authors = { 'Adam Michael' => 'adam@ajmichael.net',
                'Carter Grove' => 'grovecj@rose-hulman.edu',
                'David Robinson' => 'robinsdm@rose-hulman.edu',
                'Dan Hanson' => 'hansondg@rose-hulman.edu' }

  s.homepage = 'https://github.com/csse497/pathfinder'

  s.source = { :git => 'https://github.com/csse497/pathfinder-ios.git',
               :tag => "#{s.version}" }

  s.framework = 'Foundation'

  s.source_files = 'framework/Pathfinder/*.{h,swift}'
  s.exclude_files = '**/*{TestCase,Tests}.{h,swift}'

  s.dependency 'Starscream'
end

