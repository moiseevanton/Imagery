//
//  ViewController.swift
//  Imagery
//
//  Created by Anton Moiseev on 2016-06-14.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import UIKit
import GPUImage

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
    var historyOfFilters: [(UIImage, Filter)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make EVC the data source and the delegate for the filter collection
        self.filterCollection.dataSource = self
        self.filterCollection.delegate = self
        
        // move the first and last cells by 10
        self.filterCollection.contentInset = UIEdgeInsetsMake(0, 9, 0, 9)
        
        // set up different filters
        setUpFilters()
        
        // get processed images by applying those filters
        applyFiltersToThumbnails(filterArray!, image: lowResOriginalPhoto!)
        
        // set up the bottom buttons
        setUpBottomButtons()
        
        // set up the filter control
        setUpFilterControl()
        
        // get the selected filter group
        getSelectedFilterGroup()
        
        // create copy of the original photo
        let cgi = CGImageCreateCopy(originalPhoto!.CGImage)
        copyOfOriginalPhoto = UIImage(CGImage: cgi!, scale: 1.0, orientation: originalPhoto!.imageOrientation)
        
        // set original photo as the image of the image view
        photoView.image = originalPhoto
        
        // hide navigation bar
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Setting up the controls
    
    func setUpBottomButtons() {
        
        let buttonSymoblArray = ["⨯", "↩︎", "✓"]
        let buttonArray = [].mutableCopy()
        var count: Int = 1
        for symbol in buttonSymoblArray {
            let newButton = UIButton(type: .System)
            newButton.tintColor = UIColor.lightGrayColor()
            let font = UIFont(name: UIFont.familyNames()[0], size: 20)
            newButton.titleLabel?.font = font
            newButton.showsTouchWhenHighlighted = true
            newButton.setTitle(symbol, forState: .Normal)
            newButton.backgroundColor = UIColor.blackColor()
            newButton.addTarget(self, action: #selector(EditViewController.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            buttonArray.addObject(newButton)
            newButton.tag = count
            count += 1
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
        stack.heightAnchor.constraintEqualToConstant(30).active = true
        stack.bottomAnchor.constraintEqualToAnchor(bottomBar.bottomAnchor, constant: 0).active = true
        stack.leftAnchor.constraintEqualToAnchor(bottomBar.leftAnchor, constant: 0).active = true
        stack.rightAnchor.constraintEqualToAnchor(bottomBar.rightAnchor, constant: 0).active = true
        bottomButtonStack = stack
        bottomButtonStack?.hidden = !bottomBarIsOpen
    }
    
    func setUpFilterControl() {
        let segmentedControl = UISegmentedControl.init(items: ["standard", "special", "distorted"])
        segmentedControl.tintColor = UIColor.darkGrayColor()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        bottomBar.addSubview(segmentedControl)
        
        // add action
        segmentedControl.addTarget(self, action: #selector(EditViewController.segmentedControlTapped(_:)), forControlEvents: .ValueChanged)
        
        // add constraints
        segmentedControl.heightAnchor.constraintEqualToConstant(45).active = true
        segmentedControl.bottomAnchor.constraintEqualToAnchor(bottomBar.bottomAnchor, constant: -30).active = true
        segmentedControl.leftAnchor.constraintEqualToAnchor(bottomBar.leftAnchor, constant: 0).active = true
        segmentedControl.rightAnchor.constraintEqualToAnchor(bottomBar.rightAnchor, constant: 0).active = true
        filterControl = segmentedControl
        filterControl?.hidden = !bottomBarIsOpen
    }
    
    func setUpFilters() {
        
        // low res version of the original photo
        UIGraphicsBeginImageContext(CGSizeMake(originalPhoto!.size.width/10, originalPhoto!.size.height/10))
        originalPhoto?.drawInRect(CGRectMake(0, 0, originalPhoto!.size.width/10, originalPhoto!.size.height/10))
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
        
        let sic1 = GPUImagePicture.init(image: lowResOriginalPhoto)
        let shf1 = GPUImageSharpenFilter.init()
        shf1.sharpness = -0.1
        let saf1 = GPUImageSaturationFilter.init()
        saf1.saturation = 1.5
        let cf1 = GPUImageContrastFilter.init()
        cf1.contrast = 1.5
        shf1.addTarget(saf1)
        saf1.addTarget(cf1)
        let gf1 = GPUImageFilterGroup.init()
        gf1.initialFilters = [shf1]
        gf1.terminalFilter = cf1
        sic1.addTarget(gf1)
        
        // special filters
        
        let polkaDotFilter = GPUImagePolkaDotFilter.init()
        polkaDotFilter.dotScaling = 1.15
        polkaDotFilter.fractionalWidthOfAPixel = 0.007
        
        let pixellateFilter = GPUImagePixellateFilter.init()
        pixellateFilter.fractionalWidthOfAPixel = 0.006
        
        let sketchFilter = GPUImageSketchFilter.init()
        sketchFilter.edgeStrength = 1.1
        
        let posterizeFilter = GPUImagePosterizeFilter.init()
        posterizeFilter.colorLevels = 8
        
        let vignetteFilter = GPUImageVignetteFilter.init()
        
        let sic2 = GPUImagePicture.init(image: lowResOriginalPhoto)
        let gsf1 = GPUImageGrayscaleFilter.init()
        let ef1 = GPUImageErosionFilter.init()
        let cf2 = GPUImageContrastFilter.init()
        cf2.contrast = 1.1
        let sf2 = GPUImageSaturationFilter.init()
        sf2.saturation = 1.2
        let shf2 = GPUImageSharpenFilter.init()
        shf2.sharpness = 2.0
        gsf1.addTarget(ef1)
        ef1.addTarget(cf2)
        cf2.addTarget(sf2)
        sf2.addTarget(shf2)
        let gf2 = GPUImageFilterGroup.init()
        gf2.initialFilters = [gsf1]
        gf2.terminalFilter = shf2
        sic2.addTarget(gf2)
        
        let smoothToonFilter = GPUImageSmoothToonFilter.init()
        smoothToonFilter.blurRadiusInPixels = 1.0
        smoothToonFilter.threshold = 0.3
        smoothToonFilter.quantizationLevels = 10.0
        
        // distortion filters
        let swirlFilter = GPUImageSwirlFilter.init()
        
        let bulgeDistortionFilter = GPUImageBulgeDistortionFilter.init()
        
        let pinchDistortionFilter = GPUImagePinchDistortionFilter.init()
        
        let stretchDistortionFilter = GPUImageStretchDistortionFilter.init()
        
        // add them all to an array
        filterArray = [Filter.init(type: GPUImageSepiaFilter.init(), name: "SP", group: .Standard, source: nil),
                       Filter.init(type: GPUImageGrayscaleFilter.init(), name: "GS", group: .Standard, source: nil),
                       Filter.init(type: GPUImageHazeFilter.init(), name: "HZ", group: .Standard, source: nil),
                       Filter.init(type: whiteBalanceFilter, name: "WB", group: .Standard, source: nil),
                       Filter.init(type: gf1, name: "MX", group: .Standard , source: sic1),
                       Filter.init(type: monochromeFilter, name: "MN", group: .Standard, source: nil),
                       Filter.init(type: hueFilter, name: "HUE", group: .Standard, source: nil),
                       Filter.init(type: GPUImageColorInvertFilter.init(), name: "CI", group: .Standard, source: nil),
                       Filter.init(type: falseColorFilter, name: "FC", group: .Standard, source: nil),
                       Filter.init(type: polkaDotFilter, name: "PD", group: .Special, source: nil),
                       Filter.init(type: pixellateFilter, name: "PX", group: .Special, source: nil),
                       Filter.init(type: posterizeFilter, name: "PS", group: .Special, source: nil),
                       Filter.init(type: vignetteFilter, name: "VG", group: .Special, source: nil),
                       Filter.init(type: smoothToonFilter, name: "ST", group: .Special, source: nil),
                       Filter.init(type: gf2, name: "DL", group: .Special, source: sic2),
                       Filter.init(type: sketchFilter, name: "SK", group: .Special, source: nil),
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
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(EditViewController.changeCenter(_:)))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditViewController.changeCenter(_:)))
            photoView.userInteractionEnabled = true
            photoView.addGestureRecognizer(pinchGesture)
            photoView.addGestureRecognizer(panGesture)
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
            self.BottomBarHeightConstraint.constant = self.bottomBarIsOpen ? 95 : 20
            self.topConstraint.constant = self.bottomBarIsOpen ? -67: 8
            self.view.layoutIfNeeded()
            }, completion: nil)
        bottomButtonStack?.hidden = !bottomBarIsOpen
        filterControl?.hidden = !bottomBarIsOpen
    }
    
    func buttonTapped(sender: UIButton) {
        
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
        } else {
            quickFilteredImage = filter.type.imageByFilteringImage(img)
        }
        if historyOfFilters.count == 0 {
            historyOfFilters.append((quickFilteredImage!, filter))
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
            if filterBundle.group == FilterGroup.Distortion {
                let filter = filterBundle.type
                if ip?.item == 0 {
                    let theFilter = filter as! GPUImageSwirlFilter
                    theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                    photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                } else if ip?.item == 1 {
                    let theFilter = filter as! GPUImageBulgeDistortionFilter
                    theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                    photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                } else if ip?.item == 2 {
                    let theFilter = filter as! GPUImagePinchDistortionFilter
                    theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                    photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                } else {
                    let theFilter = filter as! GPUImageStretchDistortionFilter
                    theFilter.center = CGPointMake(touchPoint.x/photoView.frame.size.width, touchPoint.y/photoView.frame.size.height)
                    photoView.image = applyFilter(filterBundle, img: copyOfOriginalPhoto!)
                }
            }
        }
    }
}

