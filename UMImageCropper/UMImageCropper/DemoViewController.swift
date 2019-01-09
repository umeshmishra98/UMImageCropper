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
        let imageObj = UIImage(named: "Edu")
        let circleCropController = UMImageCropper(withImage: imageObj!, withCropperFrame: CGRect(x: 0, y: 0, width: 325, height: 100), withCircularOverlay: true, andProvideCircularImage: false)
        circleCropController.viewBackgroundColor = .green
        circleCropController.overlayColor = UIColor.brown.withAlphaComponent(0.3)
        circleCropController.scrollViewColor = .purple
        circleCropController.borderColor = .white
        circleCropController.borderSize = 8.0
        
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

