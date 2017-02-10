//
//  DemoImageView.swift
//  AACameraView
//
//  Created by Engr. Ahsan Ali on 07/02/2017.
//  Copyright © 2017 AA-Creations. All rights reserved.
//

import UIKit


class DemoImageView: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let validImage = self.image {
            self.imageView.image = validImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
