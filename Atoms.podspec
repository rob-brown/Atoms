Pod::Spec.new do |s|
  s.name         = "Atoms"
  s.version      = "0.0.1"
  s.summary      = "Simple, reusable components."
  s.description  = <<-DESC
                   A collection of simple, reusable components.
                   These components may be used all together or just a subset using subspecs.
                   DESC

  s.homepage = "https://github.com/rob-brown/Atoms"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Robert Brown" => "ammoknight@gmail.com" }
  s.social_media_url = "https://twitter.com/robby_brown"
  s.platform = :ios, "8.0"
  s.source = { :git => "https://github.com/rob-brown/Atoms.git", :tag => "0.0.1" }

  s.subspec 'Core' do |ss|
    ss.source_files = "Atoms/Core/**/*.{h,m}"
    ss.public_header_files = "Atoms/Core/**/*.h"
  end

  s.subspec 'DataSourceCombinators' do |ss|
    ss.dependency 'Atoms/Core'
    ss.source_files = "Atoms/DataSourceCombinators/**/*.{h,m}"
    ss.public_header_files = "Atoms/DataSourceCombinators/**/*.h"
  end

  s.subspec 'SmartViews' do |ss|
    ss.dependency 'Atoms/Core'
    ss.source_files = "Atoms/SmartViews/**/*.{h,m}"
    ss.public_header_files = "Atoms/SmartViews/**/*.h"
  end
end
