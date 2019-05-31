//
//  AACameraView+Helper.swift
//  AACameraView
//
//  Created by Engr. Ahsan Ali on 07/02/2017.
//  Copyright © 2017 AA-Creations. All rights reserved.
//

import AVFoundation

// MARK: - UIColor extenison
extension UIColor {
    
    /// hex value for color
    ///
    /// - Parameter rgb: hex value
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// MARK: - AVCaptureSession extension
extension AVCaptureSession {
    
    /// Set camera view quality for given output mode to current capture session
    ///
    /// - Parameters:
    ///   - quality: OUTPUT_QUALITY
    ///   - mode: OUTPUT_MODE
    func setQuality(_ quality: OUTPUT_QUALITY, mode: OUTPUT_MODE) {
        
        var sessionPreset = AVCaptureSession.Preset.low
        switch quality {
        case .low:
            sessionPreset = AVCaptureSession.Preset.low
        case .medium:
            sessionPreset = AVCaptureSession.Preset.medium
        case .high:
            sessionPreset = mode == .image ? AVCaptureSession.Preset.photo : AVCaptureSession.Preset.high
            
        }
        if self.canSetSessionPreset(sessionPreset) {
            self.beginConfiguration()
            self.sessionPreset = sessionPreset
            self.commitConfiguration()
        }
    }
    
    /// Set output device to current capture session
    ///
    /// - Parameter output: AVCaptureOutput
    func setOutput(_ output: AVCaptureOutput) {
        
        if canAddOutput(output) {
            beginConfiguration()
            addOutput(output)
            commitConfiguration()
        }
    }
    
    
    /// Set flash mode for given devices along flash mode to current capture session
    ///
    /// - Parameters:
    ///   - devices: [AVCaptureDevice]
    ///   - flashMode: AVCaptureFlashMode
    func setFlashMode(_ devices: [AVCaptureDevice], flashMode: AVCaptureDevice.FlashMode) {
        self.beginConfiguration()
        devices.forEach { (device) in
            if (device.position == .back) {
                if (device.isFlashModeSupported(flashMode)) {
                    do {
                        try device.lockForConfiguration()
                    } catch {
                        return
                    }
                    device.flashMode = flashMode
                    device.unlockForConfiguration()
                }
            }
        }
        self.commitConfiguration()
    }
    
    /// Set camera device to current capture session
    ///
    /// - Parameters:
    ///   - position: camera position
    ///   - cameraBack: front camera
    ///   - cameraFront: back camera
    func setCameraDevice(_ position: AVCaptureDevice.Position, cameraBack: AVCaptureDevice?, cameraFront: AVCaptureDevice?) {
        beginConfiguration()
        let inputs = self.inputs
        
        inputs.forEach { (input) in
            if let deviceInput = input as? AVCaptureDeviceInput {
                if deviceInput.device == cameraBack && position == .front {
                    removeInput(deviceInput)
                } else if deviceInput.device == cameraFront && position == .back {
                    removeInput(deviceInput)
                }
            }
        }
        
        switch position {
        case .front:
            if let validFrontDevice = cameraFront?.isValid {
                if !inputs.contains(validFrontDevice) {
                    addInput(validFrontDevice)
                }
            }
        case .back:
            if let validBackDevice = cameraBack?.isValid {
                if !inputs.contains(validBackDevice) {
                    addInput(validBackDevice)
                }
            }
        default:
            break
        }
        
        commitConfiguration()
        
    }
    
    
    ///  Set preview layer for current camera view
    ///
    /// - Parameter cameraView: camera view
    /// - Returns: AVCaptureVideoPreviewLayer
    func setPreviewLayer(_ cameraView: UIView) -> AVCaptureVideoPreviewLayer? {
        let layer = AVCaptureVideoPreviewLayer(session: self)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        DispatchQueue.main.async(execute: { () -> Void in
            layer.frame = cameraView.layer.bounds
            cameraView.clipsToBounds = true
            cameraView.layer.addSublayer(layer)
        })
        return layer
    }
    
    ///  Add mic input to current capture session
    ///
    /// - Parameter device: AVCaptureDevice
    func addMicInput( _ device: AVCaptureDevice?) {
        if let validMic = device?.isValid {
            addInput(validMic)
        }
    }
    
    ///  Remove mic input to current capture session
    ///
    /// - Parameter device: AVCaptureDevice
    func removeMicInput(_ device: AVCaptureDevice?) {
        let inputs = self.inputs
        for input in inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                if deviceInput.device == device {
                    removeInput(deviceInput)
                    break
                }
            }
        }
    }
    
}


// MARK: - AVCaptureDevice extension
extension AVCaptureDevice {
    
    /// Check if device is valid or not
    var isValid: AVCaptureDeviceInput? {
        do {
            return try AVCaptureDeviceInput(device: self)
        } catch let error {
            print("AACameraView - ", error.localizedDescription)
            return nil
        }
    }
    
    /// Set Zoom in/out with gesture for current camera view
    ///
    /// - Parameters:
    ///   - factor: current zoom factor
    ///   - gesture: UIPinchGestureRecognizer
    /// - Returns: updated zoom factor
    func setZoom(_ factor: CGFloat , gesture: UIPinchGestureRecognizer) -> CGFloat {
        
        var zoom = factor
        var vZoomFactor = gesture.scale * factor
        if gesture.state == .ended {
            zoom = vZoomFactor >= 1 ? vZoomFactor : 1
        }
        
        do {
            try lockForConfiguration()
            defer {unlockForConfiguration()}
            
            guard vZoomFactor <= activeFormat.videoMaxZoomFactor && vZoomFactor >= 1 else {
                return factor
            }
            videoZoomFactor = vZoomFactor
            
        } catch {
            print("AACameraView - \(error.localizedDescription)")
        }
        
        return zoom
    }
    
    
    /// Set Focus with gesture for current camera view
    ///
    /// - Parameters:
    ///   - view: camera view
    ///   - previewLayer: preview layer
    ///   - gesture: UITapGestureRecognizer
    func setFocus(_ view: UIView, previewLayer: AVCaptureVideoPreviewLayer, gesture: UITapGestureRecognizer) {
        let touchPoint: CGPoint = gesture.location(in: view)
        let convertedPoint: CGPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        if isFocusPointOfInterestSupported && isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
            do {
                try lockForConfiguration()
                focusPointOfInterest = convertedPoint
                focusMode = AVCaptureDevice.FocusMode.autoFocus
                unlockForConfiguration()
            } catch {
                print("AACameraView = Unable to focus")
            }
        }
        
    }
}

// MARK: - UIView extension
extension UIView {
    /// Add or remove gesture recognizer for current view
    ///
    /// - Parameters:
    ///   - flag: Bool
    ///   - gesture: UIGestureRecognizer
    func toggleGestureRecognizer(_ flag: Bool, gesture: UIGestureRecognizer) {
        
        guard flag else {
            removeGestureRecognizer(gesture)
            return
        }
        addGestureRecognizer(gesture)
    }
}

// MARK: - Helper public functions only
extension AACameraView {
    
    /// Gets recorded duration
    open var recordedDuration: CMTime {
        return outputVideo?.recordedDuration ?? CMTime.zero
    }
    
    /// Gets recorded file size
    open var recordedFileSize: Int64 {
        return outputVideo?.recordedFileSize ?? 0
    }
    
    /// Check for flash light device
    open var hasFlash: Bool {
        return self.global.cameraBack?.hasFlash ?? false
    }
    
    /// Check for front camera device
    open var hasFrontCamera: Bool {
        return self.global.cameraFront != nil ? true : false
    }
    
    /// Gets status of camera authorization
    ///
    /// - Returns: AVAuthorizationStatus
    open var status: AVAuthorizationStatus {
        return self.global.status
    }
    
    /// Toggle camera devices back and front
    open func toggleCamera() {
        self.cameraPosition = self.cameraPosition == .front ? .back : .front
    }
    
    /// Toggle camera mode to image and video
    open func toggleMode() {
        self.outputMode = self.outputMode == .image ? .videoAudio : .image
    }
    
    /// Toggle flash light on and off
    open func toggleFlash() {
        self.flashMode = self.flashMode == .on ? .off : .on
    }
    
    /// Triggers camera for getting the response
    open func triggerCamera() {
        captureImage()
        startVideoRecording()
        stopVideoRecording()
    }
    
    /// Request for authorization to access the camera devices
    ///
    /// - Parameter completion: response completion
    open func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (alowedAccess) -> Void in
            if self.outputMode == .videoAudio {
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (alowedAccess) -> Void in
                    DispatchQueue.main.sync(execute: { () -> Void in
                        completion(alowedAccess)
                    })
                })
            } else {
                DispatchQueue.main.sync(execute: { () -> Void in
                    completion(alowedAccess)
                })
                
            }
        })
    }
    
}




