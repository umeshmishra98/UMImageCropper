//
//  ViewController.swift
//  UMImageCropper
//
//  Created by Umesh Mishra on 09/01/19.
//

import UIKit


class DemoViewController: UIViewController {
    
    @IBOutlet var myImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func callImagePicker() {
        
        // to get circular image please provide same width and heiht in cropper frame.
        // to get square image with circular overlay set withCircularOverlay = true
        // to get circular image set both withCircularOverlay = true and andProvideCircularImage = true. if you only set andProvideCircularImage = true, it will not return circular image.
        
        let imageObj = UIImage(named: "SonGoku")
        let circleCropController = UMImageCropper(withImage: imageObj!, withCropperFrame: CGRect(x: 0, y: 0, width: 300, height: 300), withCircularOverlay: true, andProvideCircularImage: true)
        circleCropController.viewBackgroundColor = .white
        circleCropController.overlayColor = UIColor.black.withAlphaComponent(0.7)
        circleCropController.scrollViewColor = .lightGray
        circleCropController.borderColor = .darkGray
        circleCropController.borderSize = 2.0
        
        circleCropController.viewDismissCompletion = { imageObj in
            
            if imageObj != nil{
                self.myImageView.image = imageObj
            }
            circleCropController.dismiss(animated: true, completion: nil)
        }
        self.present(circleCropController, animated: false, completion: nil)
    }
    
    @IBAction func cropImageButtonTapped(_ sender: UIButton){
        callImagePicker()
    }


}

