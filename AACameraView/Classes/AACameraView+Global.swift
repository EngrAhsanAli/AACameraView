//
//  AACameraView+Global.swift
//  AACameraView
//
//  Created by Engr. Ahsan Ali on 09/02/2017.
//  Copyright © 2017 AA-Creations. All rights reserved.
//

import AVFoundation


class AACameraViewGlobal {
    
    let queue = DispatchQueue(label: "AACameraViewSessionQueue", attributes: [])
    
    let devicesVideo = AVCaptureDevice.devices(for: AVMediaType.video)
    
    let deviceAudio = AVCaptureDevice.default(for: AVMediaType.audio)
    
    lazy var cameraFront: AVCaptureDevice? = {
        return self.devicesVideo.filter{$0.position == .front}.first
    }()
    
    lazy var cameraBack: AVCaptureDevice? = {
        return self.devicesVideo.filter{$0.position == .back}.first
    }()
    
    
    let status: AVAuthorizationStatus = {
        guard
            UIImagePickerController.isCameraDeviceAvailable(.rear) ||
                UIImagePickerController.isCameraDeviceAvailable(.front)
            else { fatalError("AACameraView - No camera device found") }
        
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }()
    
    lazy var tempMoviePath: URL = {
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("AACameraViewMovie").appendingPathExtension("mp4").absoluteString
        if FileManager.default.fileExists(atPath: tempPath) {
            do {
                try FileManager.default.removeItem(atPath: tempPath)
            } catch {
                print("AACameraView - Error saving file")
            }
        }
        return URL(string: tempPath)!
    }()
    
    
}

public enum OUTPUT_MODE {
    case image, videoAudio, video
}

public enum OUTPUT_QUALITY {
    case low, medium, high
}


