//
//  ViewController+Social.swift
//  Imagery
//
//  Created by Jayesh Wadhwani on 2016-06-20.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import Foundation
import Social
import Material

extension MainViewController {

func postOnTwitter()
    {
    
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            let index = collectionView.indexPathsForSelectedItems()?.last
            twitterSheet.setInitialText("Shared from Imagery App")
            let photo: Photo = photos[index!.item]
            let imageData: NSData = photo.image!
            let image: UIImage = UIImage(data: imageData)!
            twitterSheet.addImage(image)
            
            self.presentViewController(twitterSheet, animated: true, completion: nil)
           
            twitterSheet.completionHandler = {(result: SLComposeViewControllerResult) in
                
                switch (result) {
                case (.Cancelled):
                break
                case (.Done):
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let alert = UIAlertController(title: "WoW", message: "Posted on Twitter", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        
                        
                        
                    }

                    
                    //print("done")
                   
                break
                
                }
                
            
                
            
            
            }
            
         
        
        
        
        
        
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
    
    
    
    
    
    
    
    
    
    }


    func postOnFacebook()
        
    {
    
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            let index = collectionView.indexPathsForSelectedItems()?.last

            facebookSheet.setInitialText("Shared from  Imagery App")
            let photo: Photo = photos[index!.item]
            let imageData: NSData = photo.image!
            let image: UIImage = UIImage(data: imageData)!
            facebookSheet.addImage(image)
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    
    
    }




}