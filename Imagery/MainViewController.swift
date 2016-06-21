//
//  MainViewController.swift
//  Imagery
//
//  Created by Jayesh Wadhwani on 2016-06-14.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import UIKit
import ALCameraViewController

class MainViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate  {

   
    @IBOutlet weak var greyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var greyView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
  
    
    @IBOutlet var myView: UIView!
    let kHeightShort: CGFloat = 10
    let kHeightLong: CGFloat = 50
    var stretched = false
    var deleteisSelected = false
    var images: Array<UIImage> = []
    var index:Int?
    var selectedIndexes=[]

    
    // when View Loads
    override func viewDidLoad() {
        super.viewDidLoad()
      
       
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        layout.itemSize = CGSize(width: 80, height: 100)
        layout.minimumLineSpacing=20
        self.collectionView.collectionViewLayout = layout
       
    self.collectionView.allowsMultipleSelection = true
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
  // Camera Buttons Clicked
    @IBAction func actionOnCAmera(sender: AnyObject) {
        let croppingEnabled = false
        let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { image in
        
            self.images.append(image.0!)
            self.dismissViewControllerAnimated(true, completion: { self.collectionView.reloadData() })
            
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
        
    }
    
    
     //delegate method image picker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.collectionView!.reloadData()
        
        images.append(image)
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    
    
    // Add button Clicked
    @IBAction func actionOnADD(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
   

    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CustomCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.imagePicked.image = self.images[indexPath.item]
        cell.backgroundColor = UIColor.yellowColor() // make cell more visible in our example project
        cell.layer.borderWidth = 0
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
        self.selectedIndexes = collectionView.indexPathsForSelectedItems()!
        print(selectedIndexes.count)
        
        if selectedIndexes.count > 0 {
        greyView.hidden = false
        
        }else{
        greyView.hidden =  true
        
        }
        
        
        
        var cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell?.selected == true {
            //cell?.backgroundColor = UIColor.orangeColor()
            cell?.layer.borderWidth = 4.0
            cell?.layer.borderColor = UIColor.grayColor().CGColor
            
            
            
            greyViewHeight.constant=kHeightLong
            
            
            
        }
        else
        {
            greyViewHeight.constant=kHeightShort
            cell?.layer.borderWidth = 0.0}
        
        
        
        
        
        
        UIView.animateWithDuration(2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 15, options: [], animations: {
            
             self.myView.layoutIfNeeded()
            
            
        }) {
            _ in
            
            
            
            
        }
        
        index = indexPath.item
        
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    // Cell Did DESelect
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        var cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.layer.borderWidth = 0.0
        
        self.selectedIndexes = collectionView.indexPathsForSelectedItems()!
        print(selectedIndexes.count)
        if collectionView.indexPathsForSelectedItems()!.count > 0 {
            greyView.hidden = false
            
        }else{
            greyView.hidden =  true
            
        }
        
    }
    
    
    //configure cell
    
    
    /*
     
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // Share Button clicked
   
    
    @IBAction func actionOnShare(sender: AnyObject) {
        
        
    }
    
    
    // save Button Clicked
    @IBAction func actionOnSave(sender: AnyObject) {
        print (index)
        
        if let x = index {
            let image = images[x]
            let imageData = UIImageJPEGRepresentation(image, 0.6)
            
            
            let compressedJPGImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
            
            let alert = UIAlertView(title: "Wow",
                                    message: "Your image has been saved to Photo Library!",
                                    delegate: nil,
                                    cancelButtonTitle: "Ok")
            index=nil
            alert.show()
        }else{
            
            
            let alert = UIAlertView(title: "Alert",
                                    message: "No images selected!",
                                    delegate: nil,
                                    cancelButtonTitle: "Ok")
            
            alert.show()
        }
        
        
    }
    
    
   // edit Button Clicked
    
    @IBAction func actionOnEdit(sender: AnyObject) {
        if selectedIndexes.count > 1 {
            let alertController = UIAlertController.init(title: "Warning!", message: "Cannot edit multiple photos, please choose one.", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction.init(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // pass the photo to edit view controller
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editSegue" {
            let ip = selectedIndexes.lastObject as! NSIndexPath
            let cell = collectionView.cellForItemAtIndexPath(ip) as! CustomCollectionViewCell
            let dvc = segue.destinationViewController as! EditViewController
            dvc.originalPhoto = cell.imagePicked.image
        }
    }
    
    // Delete Button Clicked
    @IBAction func actionOnDelete(sender: AnyObject) {
        
        if  collectionView.indexPathsForSelectedItems()!.count > 0
        {
        
            let idxsToRemove = collectionView.indexPathsForSelectedItems()!.map({ $0.item })
            images = images.enumerate().filter({ !idxsToRemove.contains($0.0) }).map({ $0.1 })
            print(collectionView.indexPathsForSelectedItems()!.count)
            greyView.hidden =  true
            collectionView.reloadData()
            
        }else{
            
            
            let alert = UIAlertView(title: "Alert",
                                    message: "No images selected!",
                                    delegate: nil,
                                    cancelButtonTitle: "Ok")
            
            alert.show()
        }
        
        
        
    }
    
    
    
    


}