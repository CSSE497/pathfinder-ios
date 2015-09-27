Pod::Spec.new do |s|
  s.name             = "Pathfinder"
  s.version          = "0.1.0"
  s.summary          = "Routing made easy."
  s.description      = <<-DESC
                       Pathfinder provides Routing as a Service.
                       DESC
  s.homepage         = "https://github.com/csse497/pathfinder"
  s.license          = 'MIT'
  s.author           = { "Adam Michael" => "adam@ajmichael.net" }
  s.source           = { :git => "https://github.com/csse497/pathfinder-ios.git", :tag => s.version.to_s }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Pathfinder' => ['Pod/Assets/*.png']
  }
end
