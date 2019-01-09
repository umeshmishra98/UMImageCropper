//
//  UMImageCropper.swift
//  UMImageCropper
//
//  Created by Umesh Mishra on 09/01/19.
//

import UIKit

//protocol KACircleCropViewControllerDelegate
//{
//
//    func circleCropDidCancel()
//    func circleCropDidCropImage(_ image: UIImage)
//
//}

class UMImageCropper: UIViewController, UIScrollViewDelegate {
    
//    var delegate: KACircleCropViewControllerDelegate?
    
    //These are 3 thing that will be needed from other class.
    var image: UIImage
    var cropperFrame: CGRect?
    var showCircle = false
    var provideCircularImage = false
    private var diameter:CGFloat = 0
    
    //Initialised 3 view that we will need
    private let imageView = UIImageView()
    private let scrollView = UMImageScrollView()
    private let overlayView = UMCropperOverlayView()
    
    //Remove use of these 2 varialbles.
    var widthValue =  0.0
    var heightValue = 0.0
    
    //Completion to return cropped image
    var viewDismissCompletion: ((UIImage?) -> Void)?
    
    
    //
    let label = UILabel(frame: CGRect(x: 0, y: 40, width: 130, height: 30))
    let doneButton = UIButton(frame: CGRect(x: 0, y: 40, width: 40, height: 30))
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 40, width: 40, height: 30))
    
    var titleString: String = "Move and Scale"
    var doneButtonTitle: String = "OK"
    var cancelButtonTitle: String = "Cancel"
    
    
    var viewBackgroundColor: UIColor = UIColor.blue.withAlphaComponent(0.5){
        didSet{
            self.view.backgroundColor = viewBackgroundColor
        }
    }
    var scrollViewColor: UIColor = .lightText{
        didSet{
            scrollView.backgroundColor = scrollViewColor
        }
    }
    var overlayColor: UIColor = UIColor.orange.withAlphaComponent(0.3){
        didSet{
            addOverlayView()
        }
    }
    var borderColor: UIColor = .yellow{
        didSet{
            addOverlayView()
        }
    }
    var borderSize: CGFloat = 3.0{
        didSet{
            addOverlayView()
        }
    }
    
    
    /// method to initialise the cropper view
    ///
    /// - Parameters:
    ///   - image: image that needs to be crooped
    ///   - cropperFrame: cropper frame
    ///   - showCircularOverlay: this variable will decide whether we have to show circular overlay or not.
    ///   - provideCircularImage: this variable decided whether the final image will be circular or not. This variable depends on showCircularOverlay variable, we can only provide circular image only if showCircularOverlay is true.
    init(withImage image: UIImage, withCropperFrame cropperFrame: CGRect ,withCircularOverlay showCircularOverlay: Bool, andProvideCircularImage provideCircularImage:Bool) {
        showCircle = showCircularOverlay
        self.provideCircularImage = provideCircularImage
        self.image = image
        self.cropperFrame = cropperFrame
        super.init(nibName: nil, bundle: nil)
        self.initialiseView()
    }
    
    
    /// method to change the color of different elements/views in the cropper view .
    ///
    /// - Parameters:
    ///   - backgroundColor: to change background color of the view. View beneath the overlay. It is an optional param
    ///   - scrollViewColor: to set the background color of the scroll view or the bordered area. It is an optional param
    ///   - overlayColor: to set the color of the bordered area. It is an optional param
    ///   - borderColor: to set the color of the border. It is an optional param
    func changeCropperColor(withBackgroundColor backgroundColor: UIColor?, withScrollViewColor scrollViewColor: UIColor?, withOverlayColor overlayColor: UIColor?, andBorderColor borderColor: UIColor?) {
        if let backgroundColor = backgroundColor {
            self.viewBackgroundColor = backgroundColor
        }
        if let scrollViewColor = scrollViewColor {
            self.scrollViewColor = scrollViewColor
        }
        if let overlayColor = overlayColor {
            self.overlayColor = overlayColor
        }
        if let borderColor = borderColor{
            self.borderColor = borderColor
        }
        self.view.backgroundColor = viewBackgroundColor
        scrollView.backgroundColor = scrollViewColor
        addOverlayView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: View management
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func initialiseView() {
        
        if let cropperFrame = cropperFrame{
            widthValue = Double(cropperFrame.size.width)
            heightValue = Double(cropperFrame.size.height)
        }
        //if we have make a circle we need a square. We will create circle with minimum diameter.
        if showCircle{
            if (widthValue > heightValue){
                widthValue = heightValue
            }else{
                heightValue = widthValue
            }
        }
        view.backgroundColor = viewBackgroundColor
        initialiseScrollViewWithImage()
        addOverlayView()
        setNavElements()
    }
    
    func initialiseScrollViewWithImage() {
        
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        
        scrollView.backgroundColor = scrollViewColor
        scrollView.frame = self.cropperFrame ?? CGRect.zero
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        
        //Calculate the scale as per the image.
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        scrollView.minimumZoomScale = scaleWidth
        if imageView.frame.size.width < scrollView.frame.size.width {
            print("We have the case where the frame is too small")
            scrollView.maximumZoomScale = scaleWidth * 2
        } else {
            scrollView.maximumZoomScale = 2.0
        }
        scrollView.zoomScale = scaleWidth
        
        //Center vertically: setting image vertically center in the crop view
        scrollView.contentOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.frame.size.height)/2)
        scrollView.center = view.center
        self.view.addSubview(scrollView)
    }
    
    func addOverlayView() {
        //Add in the black view. Note we make a square with some extra space +100 pts to fully cover the photo when rotated
        overlayView.frame = self.view.bounds
        overlayView.borderColor = borderColor
        overlayView.overLayColor = overlayColor
        overlayView.borderSize = borderSize
        overlayView.showCircle = showCircle
        if showCircle{
            self.diameter = CGFloat(widthValue)
            overlayView.diameter = widthValue
            
        }
        overlayView.cropperFrame = self.cropperFrame
        overlayView.center = view.center
        overlayView.draw(overlayView.frame)
        self.view.addSubview(overlayView)
    }
    
    func setNavElements() {
        //Add the label and buttons
        label.text = titleString
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = label.font.withSize(17)
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        
        doneButton.setTitle(doneButtonTitle, for: UIControl.State())
        doneButton.setTitleColor(UIColor.white, for: UIControl.State())
        doneButton.titleLabel?.font = cancelButton.titleLabel?.font.withSize(17)
        doneButton.addTarget(self, action: #selector(didTapOk), for: .touchUpInside)
        doneButton.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.sizeToFit()
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = cancelButton.titleLabel?.font.withSize(17)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        cancelButton.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        
        var yPos: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            yPos = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
        }
        if yPos <= 0 {
            yPos = 20
        }
        label.frame.origin = CGPoint(x: self.view.bounds.size.width/2 - label.frame.size.width/2, y: yPos)
        doneButton.frame.origin = CGPoint(x: self.view.bounds.size.width - doneButton.frame.size.width - 12, y: yPos)
        cancelButton.frame.origin = CGPoint(x: 12, y: yPos)
        
        self.view.addSubview(label)
        self.view.addSubview(doneButton)
        self.view.addSubview(cancelButton)
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    
    // MARK: Button taps
    
    @objc func didTapOk() {
        
        let newSize = CGSize(width: image.size.width*scrollView.zoomScale, height: image.size.height*scrollView.zoomScale)
        
        let offset = scrollView.contentOffset
        
        var xOffset = offset.x
        var yOffset = offset.y
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: widthValue, height: heightValue), false, 0)
        if showCircle{
            xOffset = offset.x + ((cropperFrame?.size.width)! - self.diameter)/2
            yOffset = offset.y + ((cropperFrame?.size.height)! - self.diameter)/2
            if self.provideCircularImage {
                let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.diameter, height: self.diameter))
                circlePath.addClip()
            }
        }
        
        var sharpRect = CGRect(x: -xOffset, y: -yOffset, width: newSize.width, height: newSize.height)
        sharpRect = sharpRect.integral
        
        image.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if viewDismissCompletion != nil{
            viewDismissCompletion!(finalImage)
        }
    }
    
    @objc func didTapCancel() {
        if viewDismissCompletion != nil{
            viewDismissCompletion!(nil)
        }
    }
}

class UMImageScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        
    }
    
    //Allow dragging outside of the scroll view bounds
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let excessWidth = (UIScreen.main.bounds.size.width - self.bounds.size.width)/2
        let excessHeight = (UIScreen.main.bounds.size.height - self.bounds.size.height)/2
        
        if self.bounds.insetBy(dx: -excessWidth, dy: -excessHeight).contains(point) {
            return self
        }
        return nil
    }
}


class UMCropperOverlayView: UIView {
    
    var showCircle = true
    var diameter: Double?
    var cropperFrame: CGRect?
    var overLayColor: UIColor = UIColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 1.0)
    var borderColor: UIColor = .darkGray
    var borderSize: CGFloat = 1.0
    
    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        overLayColor.setFill()
        
        UIRectFill(rect)
        if showCircle == true{

            let circle = UIBezierPath(ovalIn: CGRect(x: rect.size.width/2 - CGFloat(diameter!)/2, y: rect.size.height/2 - CGFloat(diameter!)/2, width: CGFloat(diameter!), height: CGFloat(diameter!)))
            context?.setBlendMode(.clear)
            UIColor.clear.setFill()
            circle.fill()
            
            //This is the same rect as the UIScrollView size 240 * 240, remains centered
            let square = UIBezierPath(rect: CGRect(x: rect.size.width/2 - (cropperFrame?.size.width)!/2, y: rect.size.height/2 - (cropperFrame?.size.height)!/2, width: (cropperFrame?.size.width)!, height: (cropperFrame?.size.height)!))
            borderColor.setStroke()
            square.lineWidth = borderSize
            context?.setBlendMode(.normal)
            square.stroke()
            
        }
        else{
            let framValue = CGRect(x: rect.size.width/2 - (cropperFrame?.size.width)!/2, y: rect.size.height/2 - (cropperFrame?.size.height)!/2, width: (cropperFrame?.size.width)!, height: (cropperFrame?.size.height)!)
            let rectangle = UIBezierPath(rect: framValue)
            context?.setBlendMode(.clear)
            UIColor.clear.setFill()
            rectangle.fill()
            borderColor.setStroke()
            rectangle.lineWidth = borderSize
            context?.setBlendMode(.normal)
            rectangle.stroke()
        }  
    }
    
    //Allow touches through the circle crop cutter view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
}
