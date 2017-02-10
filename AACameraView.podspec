
Pod::Spec.new do |s|
s.name             = 'AACameraView'
s.version          = '0.1.0'
s.summary          = 'AACameraView is a lightweight, easy-to-use and customizable camera view framework written in Swift.'

s.description      = <<-DESC
AACameraView is a lightweight, easy-to-use and customizable camera view framework, written in Swift. It uses AVFoundation framework and construct a camera view with basic options.
DESC

s.homepage         = 'https://github.com/EngrAhsanAli/AACameraView'
s.screenshots     = 'https://raw.githubusercontent.com/EngrAhsanAli/AACameraView/master/Screenshots/AACameraView.png'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'engrahsanali' => 'hafiz.m.ahsan.ali@gmail.com' }
s.source           = { :git => 'https://github.com/EngrAhsanAli/AACameraView.git', :tag => s.version.to_s }

s.ios.deployment_target = '8.0'

s.source_files = 'AACameraView/Classes/**/*'

end
