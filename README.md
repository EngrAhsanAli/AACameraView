# Table of Contents

- [AACameraView](#section-id-4)
  - [Description](#section-id-10)
  - [Demonstration](#section-id-16)
  - [Requirements](#section-id-26)
- [Installation](#section-id-32)
  - [CocoaPods](#section-id-37)
  - [Carthage](#section-id-63)
  - [Manual Installation](#section-id-82)
- [Getting Started](#section-id-87)
  - [Create object of camera view](#section-id-90)
  - [Set view object as camera view](#section-id-104)
  - [Set properties and usage](#section-id-112)
  - [Properties with description](#section-id-150)
  - [Methods with description](#section-id-151)
- [Contributions & License](#section-id-156)


<div id='section-id-4'/>

#AACameraView

[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods](https://img.shields.io/cocoapods/v/AACameraView.svg)](http://cocoadocs.org/docsets/AACameraView) [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/EngrAhsanAli/AACameraView.svg?branch=master)](https://travis-ci.org/EngrAhsanAli/AACameraView) 
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg) [![CocoaPods](https://img.shields.io/cocoapods/p/AACameraView.svg)]()


<div id='section-id-10'/>

##Description

`AACameraView` is a lightweight, easy-to-use and customizable camera view framework, written in Swift. It uses `AVFoundation` framework and construct a camera view with basic options.

<div id='section-id-16'/>

##Demonstration

You can make `AACameraView` with simple `UIView` in your storyboard.

![](https://github.com/EngrAhsanAli/AACameraView/blob/master/Screenshots/AACameraView.png)

To run the example project, clone the repo, and run `pod install` from the Example directory first.


<div id='section-id-26'/>

##Requirements

- iOS 8.0+
- Xcode 8.0+
- Swift 3+

<div id='section-id-32'/>

# Installation

`AACameraView` can be installed using CocoaPods, Carthage, or manually.


<div id='section-id-37'/>

##CocoaPods

`AACameraView` is available through [CocoaPods](http://cocoapods.org). To install CocoaPods, run:

`$ gem install cocoapods`

Then create a Podfile with the following contents:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
// Swift 3.2+ Compatibility
pod 'AACameraView'
// Swift 4 Compatibility
pod 'AACameraView', '~> 1.0'
end

```

Finally, run the following command to install it:
```
$ pod install
```



<div id='section-id-63'/>

##Carthage

To install Carthage, run (using Homebrew):
```
$ brew update
$ brew install carthage
```
Then add the following line to your Cartfile:

```
github "EngrAhsanAli/AACameraView" "master"
```

Then import the library in all files where you use it:
```swift
import AACameraView
```


<div id='section-id-82'/>

##Manual Installation

If you prefer not to use either of the above mentioned dependency managers, you can integrate `AACameraView` into your project manually by adding the files contained in the Classes folder to your project.


<div id='section-id-87'/>

#Getting Started
----------

<div id='section-id-90'/>

##Create object of camera view

Drag `UIView` object from the *Object Library* into your `UIViewController` in storyboard.

![](https://github.com/EngrAhsanAli/AACameraView/blob/master/Screenshots/Step1.png)

<div id='section-id-104'/>

##Set view object as camera view

Set the view's class to `AACameraView` in the *Identity Inspector*.
Make sure the module property is also set to  `AACameraView`.

![](https://github.com/EngrAhsanAli/AACameraView/blob/master/Screenshots/Step2.png)

<div id='section-id-112'/>

##Set properties and usage

Here's the basic usage and declaration of `AACameraView`.

**Usage**:
```swift
// IBOutlet for AACameraView
@IBOutlet weak var cameraView: AACameraView!

// Start capture session in viewWillAppear
override func viewWillAppear(_ animated: Bool) {
cameraView.startSession()
}
// Stop capture session in viewWillDisappear
override func viewWillDisappear(_ animated: Bool) {
cameraView.stopSession()
}

// Get response!
cameraView.response = { response in
if let url = response as? URL {
// Recorded video URL here
}
else if let img = response as? UIImage {
// Capture image here
}
else if let error = response as? Error {
// Handle error if any!
}
}

```

<div id='section-id-150'/>

##Properties with description

You can use following properties for `AACameraView`: 

|  Properties	 	 |  Types	      			 | Description		    				       |
|--------------------|---------------------------|---------------------------------------------|
| `zoomEnabled`   	 | `Bool`     				 | Enables zoom by gesture in AACameraView     |
| `focusEnabled`  	 | `Bool` 					 | Enables focus by gesture in AACameraView    |
| `cameraPosition`   | `AVCaptureDevicePosition` | Camera device position: `front`, `back` 	   |
| `flashMode`      	 | `AVCaptureFlashMode`   	 | Flash light mode: `on`, `off`, `auto` 	   |
| `outputMode`   	 | `OUTPUT_MODE`       		 | Camera Mode: `image`, `videoAudio`, `video` |
| `quality`     	 | `OUTPUT_QUALITY` 	  	 | Camera Quality: `low`, `medium`, `high`	   |
| `recordedDuration` | `CMTime`				  	 | Time for recorded video 	    			   |
| `recordedFileSize` | `Int64`				 	 | Size for recorded video					   |
| `hasFlash`         | `Bool` 				 	 | Check if Flash device available 	           |
| `hasFrontCamera`   | `Bool`				  	 | Check if Front camera device available 	   |
| `status`      	 | `AVAuthorizationStatus` 	 | Camera Device authorization: `authorized`   |

<div id='section-id-151'/>

##Methods with description

You can use following methods for `AACameraView`.

|  Methods 		 	     | Description		    				       |
|------------------------|---------------------------------------------|
| `startSession`   	     | Starts the capture session for AACameraView |
| `stopSession`   	     | Stops the capture session for AACameraView  |
| `startVideoRecording`  | Start video recording    				   |
| `stopVideoRecording`   | Stop video recording (response callback)    |
| `captureImage`   	 	 | Capture image (response callback)    	   |
| `toggleCamera`   	 	 | Toggle camera device: `front`, `back`   	   |
| `toggleMode`   	 	 | Toggle camera mode: `image`, `videoAudio`   |
| `toggleFlash`   	 	 | Toggle flash: `on`, `off`    			   |
| `triggerCamera`   	 | Trigger camera  (response callback)   	   |
| `requestAuthorization` | Request for camera access    			   |

> Note that the response callback will get data when trigger  `triggerCamera`, `captureImage` and `stopVideoRecording` methods.

<div id='section-id-156'/>

#Contributions & License

`AACameraView` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

Pull requests are welcome! The best contributions will consist of substitutions or configurations for classes/methods known to block the main thread during a typical app lifecycle.

I would love to know if you are using `AACameraView` in your app, send an email to [Engr. Ahsan Ali](mailto:hafiz.m.ahsan.ali@gmail.com)

