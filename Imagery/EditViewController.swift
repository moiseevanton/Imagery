//
//  ViewController.swift
//  Imagery
//
//  Created by Anton Moiseev on 2016-06-14.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import UIKit
import GPUImage
import CoreData
import Material

// MARK: EVCDelegate Protocol

protocol EVCDelegate {
    func updateCollectionView(imageData: NSData, lowResImageData: NSData, indexPath: NSIndexPath)
    func showCamera()
    func stopLoading()
}

class EditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var BottomBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var bottomBarIsOpen: Bool = false
    @IBOutlet weak var bottomBarButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var filterCollection: UICollectionView!
    var filterArray: [Filter]?
    var bottomButtonStack: UIStackView?
    var filterControl: UISegmentedControl?
    var selectedFilterGroup: [(UIImage, Filter)]?
    var originalPhoto: UIImage?
    var copyOfOriginalPhoto: UIImage?
    var lowResOriginalPhoto: UIImage?
    var standardFilters: [(UIImage, Filter)] = []
    var specialFilters: [(UIImage, Filter)] = []
    var distortedFilters: [(UIImage, Filter)] = []
    var delegate: EVCDelegate?
    var indexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // stop the activity view
        self.delegate?.stopLoading()
        
        // make EVC the data source and the delegate for the filter collection
        self.filterCollection.dataSource = self
        self.filterCollection.delegate = self
        
        // move the first and last cells by 10
        self.filterCollection.contentInset = UIEdgeInsetsMake(0, 9, 0, 9)
        
        // set up different filters
        setUpFilters()
        
        // get processed images by applying those filters
        applyFiltersToThumbnails(filterArray!, image: lowResOriginalPhoto!)
        
        // set up the filter control
        setUpFilterControl()
        
        // set up the bottom buttons
        setUpBottomButtons()
        
        // get the selected filter group
        getSelectedFilterGroup()
        
        // create copy of the original photo
        copyOfOriginalPhoto = UIImage(CGImage: originalPhoto!.CGImage!, scale: 1.0, orientation: originalPhoto!.imageOrientation)
        
        // set original photo as the image of the image view
        photoView.image = originalPhoto
        
        // hide navigation bar
        self.navigationController?.navigationBarHidden = true
        
        // change bottom bar's color
        bottomBar.backgroundColor = MaterialColor.grey.lighten1
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Setting up the controls
    
    func setUpBottomButtons() {
        
        let buttonSymoblArray = [MaterialIcon.cm.clear, MaterialIcon.cm.arrowBack, MaterialIcon.cm.check]
        let buttonArray = [].mutableCopy()
        var count: Int = 1
        for symbol in buttonSymoblArray {
            let newButton = FlatButton.init()
            newButton.tintColor = MaterialColor.grey.darken4
            newButton.sizeToFit()
            newButton.backgroundColor = MaterialColor.grey.lighten1
            newButton.pulseColor = MaterialColor.grey.darken2
            newButton.setImage(symbol, forState: .Normal)
            newButton.tag = count
            count += 1
            newButton.addTarget(self, action: #selector(EditViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            buttonArray.addObject(newButton)
        }
        
        let stack = UIStackView(arrangedSubviews: buttonArray as! [UIView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = UIColor.init(red: 147, green: 147, blue: 147, alpha: 1)
        bottomBar.addSubview(stack)
        
        // set up the stack
        stack.axis = .Horizontal
        stack.distribution = .FillEqually
        stack.alignment = .Fill
        stack.spacing = 0.3
        
        // add constraints
        stack.topAnchor.constraintEqualToAnchor(filterControl!.bottomAnchor, constant: 1).active = true
        stack.bottomAnchor.constraintEqualToAnchor(bottomBar.bottomAnchor, constant: 0).active = true
        stack.leftAnchor.constraintEqualToAnchor(bottomBar.leftAnchor, constant: 0).active = true
        stack.rightAnchor.constraintEqualToAnchor(bottomBar.rightAnchor, constant: 0).active = true
        bottomButtonStack = stack
        bottomButtonStack?.hidden = !bottomBarIsOpen
    }
    
    func setUpFilterControl() {
        let segmentedControl = UISegmentedControl.init(items: ["standard", "special", "distorted"])
        segmentedControl.tintColor = MaterialColor.grey.darken4
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        bottomBar.addSubview(segmentedControl)
        
        // add action
        segmentedControl.addTarget(self, action: #selector(EditViewController.segmentedControlTapped(_:)), forControlEvents: .ValueChanged)
        
        // add constraints
        segmentedControl.heightAnchor.constraintEqualToConstant(45).active = true
        segmentedControl.bottomAnchor.constraintEqualToAnchor(bottomBar.bottomAnchor, constant: -45).active = true
        segmentedControl.leftAnchor.constraintEqualToAnchor(bottomBar.leftAnchor, constant: 0).active = true
        segmentedControl.rightAnchor.constraintEqualToAnchor(bottomBar.rightAnchor, constant: 0).active = true
        filterControl = segmentedControl
        filterControl?.hidden = !bottomBarIsOpen
    }
    
    func setUpFilters() {
        
        // low res version of the original photo
        UIGraphicsBeginImageContext(CGSizeMake(originalPhoto!.size.width/11, originalPhoto!.size.height/11))
        originalPhoto?.drawInRect(CGRectMake(0, 0, originalPhoto!.size.width/11, originalPhoto!.size.height/11))
        lowResOriginalPhoto = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // create some custom filters
        
        // standard filters
        let hueFilter = GPUImageHueFilter.init()
        hueFilter.hue = 180
        
        let whiteBalanceFilter = GPUImageWhiteBalanceFilter.init()
        whiteBalanceFilter.temperature = 6500
        whiteBalanceFilter.tint = 50
        
        let monochromeFilter = GPUImageMonochromeFilter.init()
        monochromeFilter.intensity = 0.6
        monochromeFilter.color = GPUVector4(one: 0.2, two: 0.2, three: 0.2, four: 1.0)
        
        let falseColorFilter = GPUImageFalseColorFilter.init()
        falseColorFilter.setFirstColorRed(0.0, green: 0.0, blue: 0.5)
        falseColorFilter.setSecondColorRed(1.0, green: 0.0, blue: 0.0)
        
        // standard filter - chained #1
        let imageSource1 = GPUImagePicture.init(image: originalPhoto)
        let sf1 = GPUImageSaturationFilter.init()
        sf1.saturation = 0.5
        let mf1 = GPUImageMonochromeFilter.init()
        mf1.color = GPUVector4(one: 0.0, two: 0.0, three: 1.0, four: 1.0)
        mf1.intensity = 0.2
        let vf1 = GPUImageVignetteFilter.init()
        vf1.vignetteEnd = 0.7
        let ef1 = GPUImageExposureFilter.init()
        ef1.exposure = 0.3
        sf1.addTarget(mf1)
        mf1.addTarget(vf1)
        vf1.addTarget(ef1)
        let filterGroup1 = GPUImageFilterGroup.init()
        filterGroup1.initialFilters = [sf1]
        filterGroup1.terminalFilter = ef1
        imageSource1.addTarget(filterGroup1)
        
        let convolutionFilter1 = GPUImage3x3ConvolutionFilter.init()
        convolutionFilter1.convolutionKernel = GPUMatrix3x3.init(one: GPUVector3.init(one: 0.7, two: -3.8, three: -1), two: GPUVector3.init(one: -1.3, two: 5.2, three: -0.4), three: GPUVector3.init(one: 2.4, two: -1.4, three: 0.6))
        
        // special filters
        
        let polkaDotFilter = GPUImagePolkaDotFilter.init()
        polkaDotFilter.dotScaling = 1.15
        polkaDotFilter.fractionalWidthOfAPixel = 0.007
        
        let pixellateFilter = GPUImagePixellateFilter.init()
        pixellateFilter.fractionalWidthOfAPixel = 0.006
        
        let posterizeFilter = GPUImagePosterizeFilter.init()
        posterizeFilter.colorLevels = 7
        
        let vignetteFilter = GPUImageVignetteFilter.init()
        
        let smoothToonFilter = GPUImageSmoothToonFilter.init()
        smoothToonFilter.blurRadiusInPixels = 1.0
        smoothToonFilter.threshold = 0.5
        smoothToonFilter.quantizationLevels = 10.0
        
        let chFilter = GPUImageCrosshatchFilter.init()
        chFilter.crossHatchSpacing = 0.01
        chFilter.lineWidth = 0.0015
        
//        let kuwaharaFilter = GPUImageKuwaharaFilter.init()
        
        let motionBlurFilter = GPUImageMotionBlurFilter.init()
        motionBlurFilter.blurSize = 4.0
        
        let prewittFilter = GPUImagePrewittEdgeDetectionFilter.init()
        prewittFilter.edgeStrength = 0.8
        
        // distortion filters
        let swirlFilter = GPUImageSwirlFilter.init()
        
        let bulgeDistortionFilter = GPUImageBulgeDistortionFilter.init()
        
        let pinchDistortionFilter = GPUImagePinchDistortionFilter.init()
        
        let stretchDistortionFilter = GPUImageStretchDistortionFilter.init()
        
        // add them all to an array
        filterArray = [Filter.init(type: GPUImageSepiaFilter.init(), name: "SP", group: .Standard, source: nil),
                       Filter.init(type: GPUImageGrayscaleFilter.init(), name: "GS", group: .Standard, source: nil),
                       Filter.init(type: GPUImageHazeFilter.init(), name: "HZ", group: .Standard, source: nil),
                       Filter.init(type: filterGroup1, name: "BV", group: .Standard, source: imageSource1),
                       Filter.init(type: whiteBalanceFilter, name: "WB", group: .Standard, source: nil),
                       Filter.init(type: monochromeFilter, name: "MN", group: .Standard, source: nil),
                       Filter.init(type: convolutionFilter1, name: "CV", group: .Standard, source: nil),
                       Filter.init(type: hueFilter, name: "HUE", group: .Standard, source: nil),
                       Filter.init(type: polkaDotFilter, name: "PD", group: .Special, source: nil),
                       Filter.init(type: pixellateFilter, name: "PX", group: .Special, source: nil),
                       Filter.init(type: posterizeFilter, name: "PS", group: .Special, source: nil),
                       Filter.init(type: vignetteFilter, name: "VG", group: .Special, source: nil),
                       Filter.init(type: smoothToonFilter, name: "ST", group: .Special, source: nil),
//                       Filter.init(type: kuwaharaFilter, name: "KW", group: .Special, source: nil),
                       Filter.init(type: motionBlurFilter, name: "MB", group: .Special, source: nil),
                       Filter.init(type: prewittFilter, name: "PW", group: .Special, source: nil),
                       Filter.init(type: chFilter, name: "CH", group: .Special, source: nil),
                       Filter.init(type: falseColorFilter, name: "FC", group: .Special, source: nil),
                       Filter.init(type: swirlFilter, name: "SW", group: .Distortion, source: nil),
                       Filter.init(type: bulgeDistortionFilter, name: "BD", group: .Distortion, source: nil),
                       Filter.init(type: pinchDistortionFilter, name: "PD", group: .Distortion, source: nil),
                       Filter.init(type: stretchDistortionFilter, name: "SD", group: .Distortion, source: nil)]
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (selectedFilterGroup?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as! FilterCell
        let filterTuple = selectedFilterGroup![indexPath.item]
        // make sure the cell is selected while scrolling through the collection view
        if filterCollection.indexPathsForSelectedItems()?.count == 1 {
            let ip = filterCollection.indexPathsForSelectedItems()?.last
            if indexPath.item == ip?.item {
                cell.layer.borderWidth = 3.0
                cell.layer.borderColor = UIColor.lightGrayColor().CGColor
            } else {
                cell.layer.borderWidth = 0.0
            }
        } else {
            cell.layer.borderWidth = 0.0
        }
        if filterTuple.1.group == FilterGroup.Distortion {
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(EditViewController.changeRadius(_:)))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditViewController.changeCenter(_:)))
            photoView.userInteractionEnabled = true
            photoView.addGestureRecognizer(pinchGesture)
            photoView.addGestureRecognizer(tapGesture)
        }
        cell.displayFilter(filterTuple)
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FilterCell
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        let filterTuple = selectedFilterGroup![indexPath.item]
        photoView.image = applyFilter(filterTuple.1, img: copyOfOriginalPhoto!)
        print("select")
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCell
        cell?.layer.borderWidth = 0.0
        print("deselect")
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(51, 60)
    }
    
    // MARK: Actions
    
    @IBAction func bottomBarTouched(sender: UIButton) {
        bottomBarIsOpen = !bottomBarIsOpen
        let angle = bottomBarIsOpen ? CGFloat(M_PI) : 0
        UIView.animateWithDuration(0.25, delay: 0.0, options: [.CurveEaseInOut], animations: {
            self.bottomBarButton.transform = CGAffineTransformMakeRotation(angle)
            self.BottomBarHeightConstraint.constant = self.bottomBarIsOpen ? 115 : 25
            self.topConstraint.constant = self.bottomBarIsOpen ? -82: 8
            self.view.layoutIfNeeded()
            }, completion: nil)
        bottomButtonStack?.hidden = !bottomBarIsOpen
        filterControl?.hidden = !bottomBarIsOpen
    }
    
    func buttonTapped(sender: UIButton) {
        if sender.tag == 1 {
            navigationController?.popToRootViewControllerAnimated(true)
            delegate?.showCamera()
        } else if sender.tag == 2 {
            photoView.image = originalPhoto
            self.filterCollection.reloadData()
            let distortedFilters: NSMutableArray = []
            for filter in filterArray! {
                if filter.group == .Distortion {
                    distortedFilters.addObject(filter)
                }
            }
            let filter1 = distortedFilters[0] as! Filter
            let swirlFilter = filter1.type as! GPUImageSwirlFilter
            swirlFilter.center = CGPointMake(0.5, 0.5)
            swirlFilter.radius = 0.5
            
            let filter2 = distortedFilters[1] as! Filter
            let bulgeFilter = filter2.type as! GPUImageBulgeDistortionFilter
            bulgeFilter.center = CGPointMake(0.5, 0.5)
            bulgeFilter.radius = 0.25
            
            let filter3 = distortedFilters[2] as! Filter
            let pinchFilter = filter3.type as! GPUImagePinchDistortionFilter
            pinchFilter.center = CGPointMake(0.5, 0.5)
            pinchFilter.radius = 1.0
            
            let filter4 = distortedFilters[3] as! Filter
            let stretchFilter = filter4.type as! GPUImageStretchDistortionFilter
            stretchFilter.center = CGPointMake(0.5, 0.5)
            
        } else if sender.tag == 3 {
            let image = photoView.image!
            UIGraphicsBeginImageContext(CGSizeMake(image.size.width/5, image.size.height/5))
            image.drawInRect(CGRectMake(0, 0, image.size.width/5, image.size.height/5))
            let lowResImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            let lowResImageData = UIImageJPEGRepresentation(lowResImage, 1.0)
            delegate?.updateCollectionView(imageData!, lowResImageData: lowResImageData!, indexPath: indexPath!)
            delegate?.showCamera()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func segmentedControlTapped(sender: UISegmentedControl) {
        getSelectedFilterGroup()
        print(sender.selectedSegmentIndex)
        filterCollection.reloadData()
        let popUp = UIView(frame: self.filterCollection.frame)
        self.view.addSubview(popUp)
        UIView.animateWithDuration(0.8) {
            popUp.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
        print("Selected cells\(filterCollection.indexPathsForSelectedItems()?.count)")
    }
    
    func getSelectedFilterGroup() {
        switch self.filterControl!.selectedSegmentIndex {
        case 0:
            selectedFilterGroup = standardFilters
        case 1:
            selectedFilterGroup = specialFilters
        case 2:
            selectedFilterGroup = distortedFilters
        default:
            break
        }
    }
    
    func applyFiltersToThumbnails(filters: [Filter], image: UIImage) {
        var quickFilteredImage: UIImage?
        for filter in filters {
            quickFilteredImage = applyFilter(filter, img: image)
            switch filter.group {
            case .Standard:
                self.standardFilters.append((quickFilteredImage!, filter))
            case .Special:
                self.specialFilters.append((quickFilteredImage!, filter))
            case .Distortion:
                self.distortedFilters.append((quickFilteredImage!, filter))
            }
        }
    }
    
    func applyFilter(filter: Filter, img: UIImage) -> UIImage {
        var quickFilteredImage: UIImage?
        if (filter.source != nil) {
            filter.type.useNextFrameForImageCapture()
            filter.source?.processImage()
            quickFilteredImage = filter.type.imageFromCurrentFramebuffer()
            quickFilteredImage = UIImage(CGImage: quickFilteredImage!.CGImage!, scale: 1.0, orientation: originalPhoto!.imageOrientation)
        } else {
            quickFilteredImage = filter.type.imageByFilteringImage(img)
        }
        return quickFilteredImage!
    }
    
    func changeRadius(sender: UIPinchGestureRecognizer) {
        if filterCollection.indexPathsForSelectedItems()?.count == 1 && sender.numberOfTouches() == 2 {
            let ip = filterCollection.indexPathsForSelectedItems()?.last
            let filterTuple = selectedFilterGroup![ip!.item]
            let filterBundle = filterTuple.1
            let dx = sender.locationOfTouch(1, inView: photoView).x - sender.locationOfTouch(0, inView: photoView).x
            let dy = sender.locationOfTouch(1, inView: photoView).y - sender.locationOfTouch(0, inView: photoView).y
            let normalizedDifference = sqrt(pow(dx, 2) + pow(dy, 2))/sqrt(pow(photoView.frame.size.height, 2) + pow(photoView.frame.size.width, 2))
            if filterBundle.group == FilterGroup.Distortion {
                let filter = filterBundle.type
                if ip?.item == 0 {
                    let theFilter = filter as! GPUImageSwirlFilter
                    theFilter.radius = normalizedDifference
                    photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                } else if ip?.item == 1 {
                    let theFilter = filter as! GPUImageBulgeDistortionFilter
                    theFilter.radius = normalizedDifference
                    photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                } else if ip?.item == 2 {
                    let theFilter = filter as! GPUImagePinchDistortionFilter
                    theFilter.radius = normalizedDifference
                    photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                } else {
                    // do nothing
                }
                
            }
        }
    }
    
    func changeCenter(sender: UIGestureRecognizer) {
        if filterCollection.indexPathsForSelectedItems()?.count == 1 {
            let ip = filterCollection.indexPathsForSelectedItems()?.last
            let filterTuple = selectedFilterGroup![ip!.item]
            let filterBundle = filterTuple.1
            let touchPoint = sender.locationInView(photoView)
            print("\(touchPoint.x), \(touchPoint.y)")
            if filterBundle.group == FilterGroup.Distortion {
                let filter = filterBundle.type
                if ip?.item == 0 {
                    let theFilter = filter as! GPUImageSwirlFilter
                    if copyOfOriginalPhoto?.size.width >= copyOfOriginalPhoto?.size.height {
                        theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    } else {
                        theFilter.center = CGPointMake(touchPoint.y/photoView.frame.size.height, 1.0 - touchPoint.x/photoView.frame.size.width)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    }
                } else if ip?.item == 1 {
                    let theFilter = filter as! GPUImageBulgeDistortionFilter
                    if copyOfOriginalPhoto?.size.width >= copyOfOriginalPhoto?.size.height {
                        theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    } else {
                        theFilter.center = CGPointMake(touchPoint.y/photoView.frame.size.height, 1.0 - touchPoint.x/photoView.frame.size.width)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    }
                } else if ip?.item == 2 {
                    let theFilter = filter as! GPUImagePinchDistortionFilter
                    if copyOfOriginalPhoto?.size.width >= copyOfOriginalPhoto?.size.height {
                        theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    } else {
                        theFilter.center = CGPointMake(touchPoint.y/photoView.frame.size.height, 1.0 - touchPoint.x/photoView.frame.size.width)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    }
                } else {
                    let theFilter = filter as! GPUImageStretchDistortionFilter
                    if copyOfOriginalPhoto?.size.width >= copyOfOriginalPhoto?.size.height {
                        theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    } else {
                        theFilter.center = CGPointMake(touchPoint.y/photoView.frame.size.height, 1.0 - touchPoint.x/photoView.frame.size.width)
                        photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
//        standardFilters.removeAll()
//        specialFilters.removeAll()
//        distortedFilters.removeAll()
//        selectedFilterGroup?.removeAll()
    }
}

