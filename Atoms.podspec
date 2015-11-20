Pod::Spec.new do |s|
  s.name         = "Atoms"
  s.version      = "0.0.9"
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
  s.source = { :git => "https://github.com/rob-brown/Atoms.git", :tag => s.version }

  s.subspec 'DataSourceCombinators' do |ss|
    ss.source_files = "Atoms/DataSourceCombinators/**/*.{h,m,swift}"
  end

  s.subspec 'SmartViews' do |ss|
    ss.source_files = "Atoms/SmartViews/**/*.{h,m,swift}"
  end

  s.subspec 'Messaging' do |ss|
    ss.source_files = "Atoms/Messaging/**/*.{h,m,swift}"
  end

  s.subspec 'Operations' do |ss|
    ss.source_files = "Atoms/Operations/**/*.{h,m,swift}"
  end
end
