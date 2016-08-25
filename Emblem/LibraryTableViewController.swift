//
//  LibraryTableViewController.swift
//  Emblem
//
//  Created by Dane Jordan on 8/18/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import SwiftyJSON

class LibraryTableViewController: UITableViewController {

    var artData = [Dictionary<String,AnyObject>]()
    var art = [UIImage?]()
    var artPlaceId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImageIdsForUser()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeLeft:")
        gesture.direction = .Left
        tableView.addGestureRecognizer(gesture)
        
        if let addImage:UIImage = UIImage(named: "right-arrow.png") {
            let backButton: UIButton = UIButton(type: UIButtonType.Custom)
            backButton.frame = CGRectMake(0, 0, 20, 20)
            backButton.contentMode = UIViewContentMode.ScaleAspectFit
            backButton.setImage(addImage, forState: UIControlState.Normal)
            backButton.addTarget(self, action: Selector("handleSwipeLeft:"), forControlEvents: .TouchUpInside)
            let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
            
            self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
        }
        
        if let addImage:UIImage = UIImage(named: "plus-symbol.png") {
            let addButton: UIButton = UIButton(type: UIButtonType.Custom)
            addButton.frame = CGRectMake(0, 0, 20, 20)
            addButton.contentMode = UIViewContentMode.ScaleAspectFit
            addButton.setImage(addImage, forState: UIControlState.Normal)
            addButton.addTarget(self, action: Selector("addArtPressed"), forControlEvents: .TouchUpInside)
            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: addButton)
            
            self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func handleSwipeLeft(recognizer: UISwipeGestureRecognizer) {
        print("swipeLeft")
        self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromLibraryView(), sender: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.art.count
    }
    
    class func getEntrySegueFromARViewController() -> String {
        return "ARToLibraryViewControllerSegue"
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func getImageIdsForUser(){
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "user/art")!
        HTTPRequest.get(url) { (response, data) in
            if response.statusCode == 200 {
                let json = JSON(data: data)
                for (_, obj):(String, JSON) in json {
                    self.artData.append(obj.dictionaryObject!)
                    self.art = Array(count: self.artData.count, repeatedValue: nil)
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ArtTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArtTableViewCell
        
        cell.thumbImageView.image = nil
        
        
        if let image = self.art[indexPath.row] {
            dispatch_async(dispatch_get_main_queue(), {
                let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                updateCell.thumbImageView.image = image
            })
        } else {
            let artID = self.artData[indexPath.row]["id"] as! Int
            let urlString = NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art/\(artID)/download"
//            let urlString = NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "storage/art/\(id)/\(id)_FULL"
            let url = NSURL(string: urlString)!
            HTTPRequest.get(url) { (response, data) in
                if response.statusCode == 200 {
                    let image = UIImage(data: data)!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.art[indexPath.row] = image
                        let updateCell: ArtTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ArtTableViewCell
                        updateCell.thumbImageView.image = image
                    })
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let art = self.art[indexPath.row]
        let artID = self.artData[indexPath.row]["id"] as! Int
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art/\(artID)/place")!
        HTTPRequest.post(["lat": Store.lat, "long": Store.long], dataType: "application/json", url: url) { (succeeded, msg) in
            if succeeded {
                self.artPlaceId = msg["id"].intValue
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.performSegueWithIdentifier(ARViewController.getUnwindSegueFromLibraryView(), sender: indexPath.row)
                })
            }
            
        }
    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ARViewController.getUnwindSegueFromLibraryView() {
            let dest = segue.destinationViewController as! ARViewController
            if sender != nil {
                let artPlaceIdStr = String(self.artPlaceId)
                dest.receiveArt(self.art[sender as! Int], artType: .IMAGE, artPlaceId: artPlaceIdStr)
            }
            
        }
    }


}
extension LibraryTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func addArtPressed() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        postImage(image)
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func postImage(image: UIImage) {
        let imageData = UIImagePNGRepresentation(image)!
        let url = NSURL(string: NSProcessInfo.processInfo().environment["DEV_SERVER"]! + "art/")!
        HTTPRequest.post(["image": imageData, "imageLength": imageData.length], dataType: "application/octet-stream", url: url) { (succeeded, msg) in
            if succeeded {
                print(msg)
                self.artData = []
                self.getImageIdsForUser()
            }
            
        }
    }
}
