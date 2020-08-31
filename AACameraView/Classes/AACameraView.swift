//
//  AACameraView.swift
//  AACameraView
//
//  Created by Engr. Ahsan Ali on 07/02/2017.
//  Copyright © 2017 AA-Creations. All rights reserved.
//

import UIKit
import AVFoundation

/// MARK:- AACameraView
@IBDesignable open class AACameraView: UIView {
    
    /// AACameraView Zoom Gesture Enabled
    @IBInspectable open var zoomEnabled: Bool = true {
        didSet {
            setPinchGesture()
        }
    }
    
    /// AACameraView Focus Gesture Enabled
    @IBInspectable open var focusEnabled: Bool = true {
        didSet {
            setFocusGesture()
        }
    }
    
    /// AACameraViewGlobal object for one time initialization in AACameraView
    lazy var global: AACameraViewGlobal = {
        return AACameraViewGlobal()
    }()
    
    /// Gesture for zoom in/out in AACameraView
    lazy var pinchGesture: UIPinchGestureRecognizer = {
        return UIPinchGestureRecognizer(target: self,
                                        action: #selector(AACameraView.pinchToZoom(_:)))
    }()
    
    /// Gesture to focus in AACameraView
    lazy var focusGesture: UITapGestureRecognizer = {
        let instance = UITapGestureRecognizer(target: self,
                                              action: #selector(AACameraView.tapToFocus(_:)))
        instance.cancelsTouchesInView = false
        return instance
    }()
    
    
    /// Callback closure for getting the AACameraView response
    open var response: ((_ response: Any?) -> ())?
    
    /// Preview layrer for AACameraView
    open var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Zoom factor for AACameraView
    var zoomFactor: CGFloat = 1
    
    /// Capture Session for AACameraView
    var session: AVCaptureSession!
    
    /// Current output for capture session
    var output: AVCaptureOutput = AVCaptureStillImageOutput() {
        didSet {
            session.removeOutput(oldValue)
            session.setOutput(output)
        }
    }
    
    /// Video Output
    var outputVideo: AVCaptureMovieFileOutput? {
        return self.output as? AVCaptureMovieFileOutput
    }
    
    /// Image Output
    var outputImage: AVCaptureStillImageOutput? {
        return self.output as? AVCaptureStillImageOutput
    }
    
    /// Getter for current camera device
    var currentDevice: AVCaptureDevice? {
        switch cameraPosition {
        case .back:
            return global.cameraBack
        case .front:
            return global.cameraFront
        default:
            return nil
        }
    }
    
    /// Current output mode for AACameraView
    open var outputMode: OUTPUT_MODE = .image {
        didSet {
            guard outputMode != oldValue else {
                return
            }
            
            if oldValue == .videoAudio {
                session.removeMicInput(global.deviceAudio)
            }
            
            setOutputMode()
        }
    }
    
    /// Current camera position for AACameraView
    open var cameraPosition: AVCaptureDevice.Position = .back
    
    /// Current flash mode for AACameraView
    open var flashMode: AVCaptureDevice.FlashMode = AVCaptureDevice.FlashMode.auto {
        didSet {
            guard flashMode != oldValue else {
                return
            }
            setFlash()
        }
    }
    
    /// Current camera quality for AACameraView
    open var quality: OUTPUT_QUALITY = .high {
        didSet {
            guard quality != oldValue else {
                return
            }
            session.setQuality(quality, mode: outputMode)
        }
    }
    
    /// AACameraView - Interface Builder View
    open override func prepareForInterfaceBuilder() {
        let label = UILabel(frame: self.bounds)
        label.text = "AACameraView"
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.font = UIFont(name: "Gill Sans", size: bounds.width/10)
        label.sizeThatFits(intrinsicContentSize)
        self.addSubview(label)
        self.backgroundColor = UIColor(rgb: 0x2891B1)
        
    }
    
    /// Capture session starts/resumes for AACameraView
    open func startSession(position: AVCaptureDevice.Position = .back, cameraBack: Bool = true, cameraFront: Bool = true) {
        if let session = self.session {
            if !session.isRunning {
                session.startRunning()
            }
        } else {
            setSession(position: position, cameraBack: cameraBack, cameraFront: cameraFront)
        }
    }
    
    /// Capture session stops for AACameraView
    open func stopSession() {
        guard let session = session, session.isRunning else {
            return
        }
        session.stopRunning()
    }
    
    /// Start Video Recording for AACameraView
    open func startVideoRecording() {
        guard
            let output = outputVideo,
            !output.isRecording
            else { return }
        
        output.startRecording(to: global.tempMoviePath, recordingDelegate: self)
    }
    
    /// Stop Video Recording for AACameraView
    open func stopVideoRecording() {
        guard
            let output = outputVideo,
            output.isRecording
            else { return }
        
        output.stopRecording()
        
    }
    
    /// Capture image for AACameraView
    open func captureImage() {
        guard let output = outputImage, let connection = output.connection(with: .video) else { return }
        
        output.outputRectConverted(fromMetadataOutputRect: bounds)
        output.captureStillImageAsynchronously(from: connection, completionHandler: { [unowned self] response, error in
            
            guard
                error == nil,
                let response = response,
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(response),
                let image = UIImage(data: data)
                
                else {
                    self.response?(error)
                    return
            }
            
            self.response?(image)
            
        })
        
    }
    
    /// Set camera device for AACameraView
    open func setDevice(position: AVCaptureDevice.Position, cameraBack: Bool, cameraFront: Bool) {
        cameraPosition = position
        
        var _cameraBack, _cameraFront: AVCaptureDevice?
        if cameraBack {
            _cameraBack = global.cameraBack
        }
        if cameraFront {
            _cameraFront = global.cameraFront
        }
        if _cameraBack == nil, position == .back {
            cameraPosition = .front
        }
        
        session.setCameraDevice(cameraPosition, cameraBack: _cameraBack, cameraFront: _cameraFront)
    }
    
    @available(iOS 10.0, *)
    open func addBuiltIntDevice(position: AVCaptureDevice.Position) {
        cameraPosition = position
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: position),
            let validDevice = device.isValid, !session.inputs.contains(validDevice)
            else {
                print("AACameraView:- No camera. but don't all iOS 10 devices have them?")
                return
        }
        
        session.addInput(validDevice)
    }
    
//    @available(iOS 10.0, *)
//    open func captureImage(_ width: CGFloat, height: CGFloat) {
//        let settings = AVCapturePhotoSettings()
//        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [
//            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
//            kCVPixelBufferWidthKey as String: width,
//            kCVPixelBufferHeightKey as String: height
//            ] as [String : Any]
//        settings.previewPhotoFormat = previewFormat
//
//        let cameraOutput = AVCapturePhotoOutput()
//        if (session.canAddOutput(cameraOutput)) {
//            session.addOutput(cameraOutput)
//
//        }
//        cameraOutput.capturePhoto(with: settings, delegate: self)
//    }
    
}


// MARK: - UIGestureRecognizer Selectors
extension AACameraView {
    
    /// Zoom in/out selector if allowd
    ///
    /// - Parameter gesture: UIPinchGestureRecognizer
    @objc func pinchToZoom(_ gesture: UIPinchGestureRecognizer) {
        guard let device = currentDevice else {
            return
        }
        zoomFactor = device.setZoom(zoomFactor, gesture: gesture)
    }
    
    /// Focus selector if allowd
    ///
    /// - Parameter gesture: UITapGestureRecognizer
    @objc func tapToFocus(_ gesture: UITapGestureRecognizer) {
        guard
            let previewLayer = previewLayer,
            let device = currentDevice
            else {
                return
        }
        device.setFocus(self, previewLayer: previewLayer, gesture: gesture)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension AACameraView: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.response?(outputFileURL)
    }
    
    
    /// Recording did start
    ///
    /// - Parameters:
    ///   - captureOutput: AVCaptureFileOutput
    ///   - fileURL: URL
    ///   - connections: [Any]
    open func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        session.beginConfiguration()
        if flashMode != .off {
            setFlash()
        }
        session.commitConfiguration()
    }
    
    /// Recording did end
    ///
    /// - Parameters:
    ///   - captureOutput: AVCaptureFileOutput
    ///   - outputFileURL: URL
    ///   - connections: [Any]
    ///   - error: Error
    open func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        self.flashMode = .off
        let response: Any = error == nil ? outputFileURL as Any : error as Any
        self.response?(response)
    }
}

// MARK: - Setters for AACameraView
extension AACameraView {
    
    /// Set capture session for AACameraView
    func setSession(position: AVCaptureDevice.Position = .back, cameraBack: Bool = true, cameraFront: Bool = true) {
        if self.session == nil {
            self.session = AVCaptureSession()
        }
        let session = self.session!
        DispatchQueue.main.async {
            session.beginConfiguration()
            session.sessionPreset = AVCaptureSession.Preset.high
            
            if cameraBack || cameraFront {
                self.setDevice(position: position, cameraBack: cameraBack, cameraFront: cameraFront)
            }
            
            self.setOutputMode()
            self.previewLayer = session.setPreviewLayer(self)
            session.commitConfiguration()
            
            self.setFlash()
            self.setPinchGesture()
            self.setFocusGesture()
            
            session.startRunning()
            
        }
    }
    
    /// Set Output mode for AACameraView
    func setOutputMode() {
        
        session.beginConfiguration()
        
        if outputMode == .image {
            output = AVCaptureStillImageOutput()
        }
        else {
            if outputMode == .videoAudio {
                session.addMicInput(global.deviceAudio)
            }
            output = AVCaptureMovieFileOutput()
            outputVideo!.movieFragmentInterval = CMTime.invalid
        }
        
        session.commitConfiguration()
        session.setQuality(quality, mode: outputMode)
    }
    
    /// Set Flash mode for AACameraView
    func setFlash() {
        session.setFlashMode(global.devicesVideo, flashMode: flashMode)
    }
    
    /// Set Zoom in/out gesture for AACameraView
    func setPinchGesture() {
        toggleGestureRecognizer(zoomEnabled, gesture: pinchGesture)
    }
    
    /// Set Focus gesture for AACameraView
    func setFocusGesture() {
        toggleGestureRecognizer(focusEnabled, gesture: focusGesture)
    }
    
}
