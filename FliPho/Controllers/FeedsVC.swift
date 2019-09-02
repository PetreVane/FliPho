//
//  FeedsVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

class FeedsVC: UITableViewController {

    var images = [PhotoRecord]()
    var pendingOperations = PendingOperations()
    
    let url = URL(string: Flickr.apiEndPoint(where: APIMethod.isInterestingPhotos))!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

}

extension FeedsVC {
    
    // MARK: - Operations Management
    
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        switch photoRecord.state {
        case .new:
            startDownload(for: photoRecord, indexPath: indexPath)
        case .downloaded:
            stopDownload(for: photoRecord, indexPath: indexPath)
        default:
            print("FeedsVC: StartOperations() default case")
        }
        
    }
    
    func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        guard photoRecord.state == .new else { return }
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        imageFetching.completionBlock = {
            
            if imageFetching.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
                print("ImageFetcher completed task for index \(indexPath)")
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
        }
        
        pendingOperations.downloadInProgress[indexPath] = imageFetching
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
    }
    
    func stopDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
    }
    
    func suspendOperations() {
        
    }
    
    func resumeOperations() {
        
    }
    
    func loadImagesOnVisibleCells() {
        
    }
    
}


extension FeedsVC {
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    
}

extension FeedsVC {
    // MARK: - Table view delegate methods
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
