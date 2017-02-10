//
//  ViewController.swift
//  AACameraView
//
//  Created by Engr. Ahsan Ali on 07/02/2017.
//  Copyright © 2017 AA-Creations. All rights reserved.
//

import UIKit
import AACameraView



class ViewController: UIViewController {
    
    @IBOutlet weak var cameraView: AACameraView!
    
    @IBOutlet weak var captureButton: UIBarButtonItem!
    
    @IBOutlet weak var flashButton: UIBarButtonItem!
    
    @IBOutlet weak var modeButton: UIBarButtonItem!
    
    @IBOutlet weak var flipButton: UIBarButtonItem!
    
    @IBOutlet weak var permissionButton: UIBarButtonItem!
    
    @IBOutlet weak var currentMode: UILabel!
    
    var capturedImage: UIImage?
    
    var recordedVideo: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        cameraView.response = { response in
            if let url = response as? URL {
                self.recordedVideo = url
                self.performSegue(withIdentifier: "demoVideo", sender: self)
            }
            else if let img = response as? UIImage {
                self.capturedImage = img
                self.performSegue(withIdentifier: "demoImage", sender: self)
                
            }
            else if let error = response as? Error {
                print("Error: ", error.localizedDescription)
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraView.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraView.stopSession()
    }
    
    @IBAction func askForCameraPermissions(_ sender: UIBarButtonItem) {
        
        cameraView.requestAuthorization({ granted in
            if granted {
                // Permission Granted
            }
        })
    }
    
    @IBAction func toggleFlash(_ sender: UIBarButtonItem) {
        cameraView.toggleFlash()
    }
    
    @IBAction func captureAction(_ sender: UIBarButtonItem) {
        cameraView.triggerCamera()
    }
    
    @IBAction func toggleCamera(_ sender: UIBarButtonItem) {
        cameraView.toggleMode()
        switch cameraView.outputMode {
        case .image:
            captureButton.tintColor = UIColor.white
            break
        default:
            captureButton.tintColor = UIColor.red
            break
        }
        
    }
    
    @IBAction func flipCamera(_ sender: UIBarButtonItem) {
        cameraView.toggleCamera()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "demoImage" {
            let vc = segue.destination as! DemoImageView
            vc.image = self.capturedImage
        }
        else if segue.identifier == "demoVideo" {
            let vc = segue.destination as! DemoVideoPlayer
            vc.movieURL = self.recordedVideo
        }
    }
    
    
}



