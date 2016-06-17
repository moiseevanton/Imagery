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
    var bottomBarIsOpen: Bool = false
    @IBOutlet weak var bottomBarButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var filterCollection: UICollectionView!
    var filterArray: NSArray?
    var bottomButtonStack: UIStackView?
    var filterControl: UISegmentedControl?
    var selectedFilterGroup: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make EVC the data source and the delegate for the filter collection
        self.filterCollection.dataSource = self
        self.filterCollection.delegate = self
        
        // move the first and last cells by 10
        self.filterCollection.contentInset = UIEdgeInsetsMake(0, 9, 0, 9)
        
        // set up different filters
        setUpFilters()
        
        // set up the bottom buttons
        setUpBottomButtons()
        
        // set up the filter control
        setUpFilterControl()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Setting up the controls
    
    func setUpBottomButtons() {
        
        let buttonSymoblArray = ["↩︎", "⨯", "✓"]
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
        
        let sic1 = GPUImagePicture.init(image: UIImage(named: "supremeCat"))
        let shf1 = GPUImageSharpenFilter.init()
        shf1.sharpness = -0.5
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
        let motionBlurFilter = GPUImageMotionBlurFilter.init()
        motionBlurFilter.blurSize = 0.95
        
        let polkaDotFilter = GPUImagePolkaDotFilter.init()
        polkaDotFilter.dotScaling = 1.0
        polkaDotFilter.fractionalWidthOfAPixel = 0.016
        
        let pixellateFilter = GPUImagePixellateFilter.init()
        pixellateFilter.fractionalWidthOfAPixel = 0.009
        
        let sketchFilter = GPUImageSketchFilter.init()
        sketchFilter.edgeStrength = 1.1
        
        let posterizeFilter = GPUImagePosterizeFilter.init()
        posterizeFilter.colorLevels = 8
        
        let vignetteFilter = GPUImageVignetteFilter.init()
        
        // add them all to an array
        filterArray = [Filter.init(type: GPUImageSepiaFilter.init(), name: "SP", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: GPUImageGrayscaleFilter.init(), name: "GS", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: GPUImageHazeFilter.init(), name: "HZ", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: whiteBalanceFilter, name: "WB", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: gf1, name: "MX", group: FilterGroup.Standard , source: sic1),
                       Filter.init(type: monochromeFilter, name: "MN", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: hueFilter, name: "HUE", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: GPUImageColorInvertFilter.init(), name: "CI", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: falseColorFilter, name: "FC", group: FilterGroup.Standard, source: nil),
                       Filter.init(type: motionBlurFilter, name: "MB", group: FilterGroup.Special, source: nil),
                       Filter.init(type: polkaDotFilter, name: "PD", group: FilterGroup.Special, source: nil),
                       Filter.init(type: pixellateFilter, name: "PX", group: FilterGroup.Special, source: nil),
                       Filter.init(type: sketchFilter, name: "SK", group: FilterGroup.Special, source: nil),
                       Filter.init(type: posterizeFilter, name: "PS", group: FilterGroup.Special, source: nil),
                       Filter.init(type: vignetteFilter, name: "VG", group: FilterGroup.Special, source: nil)]
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // get selected group
        getSelectedFilterGroup()
        return (selectedFilterGroup?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as! FilterCell
        let filter = selectedFilterGroup![indexPath.item] as! Filter
        cell.displayFilter(filter, image: UIImage(named: "supremeCat")!)
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FilterCell
        photoView.image = cell.filterImageView.image
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
            self.view.layoutIfNeeded()
            }, completion: nil)
        bottomButtonStack?.hidden = !bottomBarIsOpen
        filterControl?.hidden = !bottomBarIsOpen
    }
    
    func buttonTapped(sender: UIButton) {
        print("heeey")
    }
    
    func segmentedControlTapped(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        filterCollection.reloadData()
        let popUp = UIView(frame: self.filterCollection.frame)
        self.view.addSubview(popUp)
        UIView.animateWithDuration(0.8) {
            popUp.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
    }
    
    func getSelectedFilterGroup() {
        let result = [].mutableCopy()
        for filter in filterArray as! [Filter] {
            if filterControl?.selectedSegmentIndex == 0 && filter.group == FilterGroup.Standard {
                result.addObject(filter)
            }
            
            if filterControl?.selectedSegmentIndex == 1 && filter.group == FilterGroup.Special {
                result.addObject(filter)
            }
            
            if filterControl?.selectedSegmentIndex == 2 && filter.group == FilterGroup.Distortion {
                result.addObject(filter)
            }
        }
        selectedFilterGroup = result as? NSArray
    }
}

