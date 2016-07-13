//
//  MainViewController.swift
//  Imagery
//
//  Created by Jayesh Wadhwani on 2016-06-14.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import UIKit
import ALCameraViewController
import CoreData
import Material
import NVActivityIndicatorView

class MainViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EVCDelegate, NSFetchedResultsControllerDelegate {
    
    var cameraButton: IconButton?
    var editButton: UIButton?
    var shareButton: UIButton?
    var buttonStack: UIStackView?
    let activityIndicator: NVActivityIndicatorView = NVActivityIndicatorView.init(frame: CGRectZero, type: .BallRotateChase, color: MaterialColor.white, padding: nil)
    @IBOutlet weak var greyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var greyView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var myView: UIView!
    let kHeightShort: CGFloat = 0
    let kHeightLong: CGFloat = 50
    var stretched = false
    var deleteisSelected = false
    var photos: [Photo] = []
    let moc: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var socialView: UIView!
    
    // when View Loads
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCameraButton()
        activityIndicator.frame = CGRectMake(self.view.center.x - 25, self.view.center.y - 25, 50, 50)
        activityIndicator.color = MaterialColor.white
        activityIndicator.layer.shadowColor = MaterialColor.black.CGColor
        activityIndicator.layer.shadowOpacity = 1.0
        self.view.addSubview(activityIndicator)
        greyView.backgroundColor = MaterialColor.grey.darken4
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        greyViewHeight.constant=kHeightShort
        configureButtonStack()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        layout.itemSize = CGSize(width: 80, height: 100)
        layout.minimumLineSpacing = 15
        self.collectionView.collectionViewLayout = layout
        self.collectionView.allowsMultipleSelection = true
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: Set up the camera button
    
    func configureCameraButton() {
        let cameraButton = IconButton.init()
        cameraButton.tintColor = MaterialColor.white
        cameraButton.setImage(UIImage(named: "aperture"), forState: .Normal)
        cameraButton.shape = MaterialShape.Circle
        cameraButton.addTarget(self, action: #selector(MainViewController.actionOnCamera(_:)), forControlEvents: .TouchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cameraButton)
        cameraButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: 0).active = true
        cameraButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -20).active = true
        cameraButton.shadowColor = MaterialColor.black
        cameraButton.shadowOpacity = 1.0
        self.cameraButton = cameraButton

    }
    
    // MARK: Setting up the stack view
    
    func configureButtonStack() {
        
        let stackView = UIStackView.init()
        stackView.distribution = .EqualCentering
        self.greyView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraintEqualToAnchor(greyView.topAnchor, constant: 4).active = true
        stackView.leftAnchor.constraintEqualToAnchor(greyView.leftAnchor, constant: 30).active = true
        stackView.rightAnchor.constraintEqualToAnchor(greyView.rightAnchor, constant: -30).active = true
        
        // cancel button
        let cancelButton = IconButton.init()
        cancelButton.tintColor = MaterialColor.white
        cancelButton.pulseColor = MaterialColor.grey.lighten3
        cancelButton.backgroundColor = MaterialColor.grey.darken4
        cancelButton.setImage(MaterialIcon.cm.close, forState: .Normal)
        cancelButton.addTarget(self, action: #selector(MainViewController.cancelPressed(_:)), forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(cancelButton)
        
        // delete button
        let deleteButton = IconButton.init()
        deleteButton.tintColor = MaterialColor.white
        deleteButton.pulseColor = MaterialColor.grey.lighten3
        deleteButton.backgroundColor = MaterialColor.grey.darken4
        deleteButton.setImage(UIImage(named: "delete_white"), forState: .Normal)
        deleteButton.addTarget(self, action: #selector(MainViewController.actionOnDelete(_:)), forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(deleteButton)
        
        // edit button
        let editButton = IconButton.init()
        editButton.tintColor = MaterialColor.white
        editButton.pulseColor = MaterialColor.grey.lighten3
        editButton.backgroundColor = MaterialColor.grey.darken4
        editButton.setImage(MaterialIcon.cm.edit, forState: .Normal)
        editButton.addTarget(self, action: #selector(MainViewController.editButtonPressed(_:)), forControlEvents: .TouchUpInside)
        self.editButton = editButton
        stackView.addArrangedSubview(editButton)
        
        // save button
        let saveButton = IconButton.init()
        saveButton.tintColor = MaterialColor.white
        saveButton.pulseColor = MaterialColor.grey.lighten3
        saveButton.backgroundColor = MaterialColor.grey.darken4
        saveButton.setImage(MaterialIcon.cm.arrowDownward, forState: .Normal)
        saveButton.addTarget(self, action: #selector(MainViewController.actionOnSave(_:)), forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(saveButton)
        
        // share button
        let shareButton = IconButton.init()
        shareButton.tintColor = MaterialColor.white
        shareButton.pulseColor = MaterialColor.grey.lighten3
        shareButton.backgroundColor = MaterialColor.grey.darken4
        shareButton.setImage(MaterialIcon.cm.share, forState: .Normal)
        shareButton.addTarget(self, action: #selector(MainViewController.actionOnShare(_:)), forControlEvents: .TouchUpInside)
        self.shareButton = shareButton
        stackView.addArrangedSubview(shareButton)
        
        // retain the stack view
        self.buttonStack = stackView
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(100, 140)
    }
    
    // MARK: Fetching photos
    
    func fetchPhotos() {
        let fetchRequest = NSFetchRequest.init()
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: self.moc)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor.init(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var result: [Photo]?
        do {
//            self.photos.removeAll()
            result = try self.moc.executeFetchRequest(fetchRequest) as? [Photo]
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        self.photos = result!
    }

    override func viewWillDisappear(animated: Bool) {
        self.moc.refreshAllObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        // get all the up-to-date photos
        self.fetchPhotos()
        self.collectionView.reloadData()
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  // Camera Buttons Clicked
    func actionOnCamera(sender: AnyObject) {
        // remove all photos
//        photos.removeAll()
        let croppingEnabled = false
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled, allowsLibraryAccess: false) { image in
            if let img = image.0 {
                let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.moc) as! Photo
                newPhoto.image = UIImageJPEGRepresentation(img, 0.6)
                // low res version of img for the cell
                UIGraphicsBeginImageContext(CGSizeMake(img.size.width/5, img.size.height/5))
                img.drawInRect(CGRectMake(0, 0, img.size.width/5, img.size.height/5))
                let lowResImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                newPhoto.thumbnail = UIImageJPEGRepresentation(lowResImage, 1.0)
                newPhoto.date = NSDate()
                do {
                    try self.moc.save()
                } catch let error as NSError {
                    print("\(error.localizedDescription)")
                }
            }
            self.dismissViewControllerAnimated(true, completion: { self.collectionView.reloadData() })
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
     //delegate method image picker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let newPhoto = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: self.moc) as! Photo
        newPhoto.image = UIImageJPEGRepresentation(image, 0.6)
        // low res version of img for the cell
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width/5, image.size.height/5))
        image.drawInRect(CGRectMake(0, 0, image.size.width/5, image.size.height/5))
        let lowResImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        newPhoto.thumbnail = UIImageJPEGRepresentation(lowResImage, 1.0)
        newPhoto.date = NSDate()
        do {
            try self.moc.save()
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    
    
    // Add button Clicked
    @IBAction func actionOnADD(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.navigationBar.barStyle = UIBarStyle.BlackOpaque
            imagePicker.navigationBar.tintColor = MaterialColor.grey.lighten3
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            // remove all photos
//            photos.removeAll()
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
        
        greyViewHeight.constant =  kHeightShort
        self.cameraButton!.hidden = false
        self.animate()

    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CustomCollectionViewCell
        // add a long press gesture recognizer to each cell
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(MainViewController.longPressActivated(_:)))
        longPress.minimumPressDuration = 0.2
        cell.addGestureRecognizer(longPress)
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let ourPhoto = self.photos[indexPath.item]
        let lowResImageData = ourPhoto.thumbnail
        let lowResImage = UIImage(data: lowResImageData!)
        cell.imagePicked.image = lowResImage
        if cell.selected {
            cell.layer.borderWidth = 4.0
            cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        } else {
            cell.layer.borderWidth = 0.0
        }
        cell.layer.cornerRadius = 5.0
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexes = collectionView.indexPathsForSelectedItems()!
        self.cameraButton!.hidden = selectedIndexes.count > 0
        self.editButton!.enabled = selectedIndexes.count <= 1
        self.shareButton!.enabled = selectedIndexes.count <= 1
        greyViewHeight.constant = selectedIndexes.count > 0 ? kHeightLong : kHeightShort
        self.animate()
        
        
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
            
        cell?.layer.borderWidth = 4.0
        cell?.layer.borderColor = UIColor.grayColor().CGColor
        greyViewHeight.constant=kHeightLong
        self.animate()
    }
    
    
    // Cell Did DESelect
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.layer.borderWidth = 0.0
        let selectedIndexes = collectionView.indexPathsForSelectedItems()!
        greyViewHeight.constant = selectedIndexes.count > 0 ? kHeightLong : kHeightShort
        self.animate()
        self.editButton!.enabled = selectedIndexes.count <= 1
        self.shareButton!.enabled = selectedIndexes.count <= 1
        self.cameraButton!.hidden = selectedIndexes.count > 0
    }
    
    // Share Button clicked
   
    
    @IBAction func actionOnShare(sender: AnyObject) {
        

        
        
        if collectionView.indexPathsForSelectedItems()?.count <= 1
        {
            // Create the alert controller
            let alertController = UIAlertController(title: "Social", message: "Choose Your Option", preferredStyle: .Alert)
            
            // Create the actions
            let facebookAction = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                 self.postOnFacebook()
           
            
            }
            let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default) {
                UIAlertAction in
               self.postOnTwitter()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                //alertController .removeFromParentViewController()
            }

            
            
            // Add the actions
            alertController.addAction(facebookAction)
            alertController.addAction(twitterAction)
            alertController.addAction(cancelAction)
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
            
        }else
        {
        
            let alertController = UIAlertController(title: "Alert", message:
                "Select a single Image to share", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            

        
        }
   
        
        
        
        }
    
    
    
    // save Button Clicked
    @IBAction func actionOnSave(sender: AnyObject) {
      
        
        if let selectedIndexes = collectionView.indexPathsForSelectedItems() {

           
            
            for idx in selectedIndexes {
                let photo = photos[idx.item]
                let imageData = photo.image
                let image = UIImage(data: imageData!)
                let jpegImage = UIImageJPEGRepresentation(image!, 0.6)
                let compressedJPGImage = UIImage(data: jpegImage!)
                UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
                
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .Center
            let titleString = NSAttributedString(string: "Hey there!", attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: MaterialColor.white])
            let messageString = NSAttributedString(string: "Selected images were successfully saved to camera roll.", attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: MaterialColor.white])
            let alertController = UIAlertController(title: "", message:
                "", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.setValue(titleString, forKey: "attributedTitle")
            alertController.setValue(messageString, forKey: "attributedMessage")
            let subview = alertController.view.subviews.first! as UIView
            let alertContentView = subview.subviews.last! as UIView
            alertContentView.backgroundColor = MaterialColor.grey.darken1
            alertContentView.layer.cornerRadius = 10
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil)
            alertController.addAction(action)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            alertController.view.tintColor = MaterialColor.black
            
        }else{
            

            
            let alertController = UIAlertController(title: "Hey!", message:
                "No images are selected, please select images that you want to save to camera roll.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
  
            
            
            
        }
        
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "editSegue" {
            let selectedIndexes = self.collectionView.indexPathsForSelectedItems()
            if selectedIndexes!.count > 1 || selectedIndexes!.count == 0 {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    // pass the photo to edit view controller
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editSegue" {
            let selectedIndexes = self.collectionView.indexPathsForSelectedItems()
            let ip = selectedIndexes?.last
            let photo = photos[(ip?.item)!] as Photo
            let dvc = segue.destinationViewController as! EditViewController
            dvc.delegate = self
            dvc.originalPhoto = UIImage(data: photo.image!)
            dvc.indexPath = ip
            greyViewHeight.constant = kHeightShort
            cameraButton!.hidden = true
        }
    }
    
    // Delete Button Clicked
    
    func actionOnDelete(sender: AnyObject) {
        
        if sender is UIButton {
            
        
        

        if  collectionView.indexPathsForSelectedItems()!.count > 0
        {
        
            let idxsToRemove = collectionView.indexPathsForSelectedItems()!.map({ $0.item })
            for index in idxsToRemove {
                let photo = photos[index]
                self.moc.deleteObject(photo)
                do {
                    try self.moc.save()
                } catch let error as NSError {
                    print("\(error.localizedDescription)")
                }
            }
            photos =  photos.enumerate().filter({ !idxsToRemove.contains($0.0) }).map({ $0.1 })
            greyViewHeight.constant =  kHeightShort
            self.cameraButton!.hidden = false
            self.animate()
            collectionView.reloadData()
            
        }else{
            
            
            let alertController = UIAlertController(title: "Hey!", message:
                "No images are selected, please select images that you want to delete.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        }
        
        
        
    }
    
    }


    func   animate(){
        
        UIView.animateWithDuration(0.3, delay: 0.09, usingSpringWithDamping: 0.8, initialSpringVelocity: 15, options: [], animations: {
            
            self.myView.layoutIfNeeded()
            
            
        }) {
            _ in
            
            
            
            
        }
        
        
        
    }
    
    // MARK: EVCDelegate
    func updateCollectionView(imageData: NSData, lowResImageData: NSData, indexPath: NSIndexPath) {
        let photo = photos[indexPath.item]
        photo.date = NSDate()
        photo.image = imageData
        photo.thumbnail = lowResImageData
        do {
            try self.moc.save()
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
//        self.photos.removeAll()
    }
    
    func showCamera() {
        cameraButton!.hidden = false
    }
    
    //MARK: Actions
    
    func cancelPressed(sender: IconButton) {
        for index in collectionView.indexPathsForSelectedItems()! {
            self.collectionView.deselectItemAtIndexPath(index, animated: false)
            let cell = self.collectionView.cellForItemAtIndexPath(index)
            cell?.layer.borderWidth = 0.0
        }
        greyViewHeight.constant = kHeightShort
        self.animate()
        cameraButton!.hidden = false
    }
    
    func editButtonPressed(sender: IconButton) {
        self.activityIndicator.startAnimation()
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("editSegue", sender: nil)
        }
        }
    
    func longPressActivated(sender: UILongPressGestureRecognizer) {
        let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        let cell = sender.view as! CustomCollectionViewCell
        detailViewController.photo = cell.imagePicked.image
        detailViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        if sender.state == UIGestureRecognizerState.Began {
            self.presentViewController(detailViewController, animated: true, completion: nil)
        }
    }
    
    func stopLoading() {
        self.activityIndicator.stopAnimation()
    }
}










