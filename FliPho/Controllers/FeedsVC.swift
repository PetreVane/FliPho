//
//  FeedsVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

class FeedsVC: UITableViewController {

    fileprivate var photoDetails: [PhotoRecord] = []
    fileprivate var pendingOperations = PendingOperations()
    fileprivate let storage = Cache()
    
    let url = FlickrURLs.fetchInterestingPhotos()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchImageDetails(from: url!)
    }

    
}

extension FeedsVC {
    
    // MARK: - Networking
    
    func fetchImageDetails(from url: URL) {
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            
            // weak capturing of self
            guard let self = self else { return }
            
            guard error == nil else { self.showAlert(with: "Errors while connecting to Flickr")
                print("Errors != nil")
                return
            }
            
            guard let serverResponse = response as? HTTPURLResponse,
                serverResponse.statusCode == 200 else { print("FeedsVC -> DownloadImages: Server responded with unexpected status code")
                    self.showAlert(with: "Flickr servers not reachable")
                    return
            }
            
            guard let receivedData = data else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let decodedData = try decoder.decode(EncodedPhotos.self, from: receivedData)
                let decodedPhotos = decodedData.photos.photo
                
                for photo in decodedPhotos {
                    
                    if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
                        let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                        self.photoDetails.append(photoRecord)
                    }
                }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    
                    }
                
            } catch {
                
                print("Errors while decoding JSON: \(error.localizedDescription)")
                // present an alert here
            }
        }
        task.resume()
    }

    func showAlert(with errorMessage: String) {
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension FeedsVC {

    // MARK: - Loading images on Visible Cells

    func loadImagesOnVisibleCells() {

        // getting a reference of all visible rows
        if let listOfVisibleRows = tableView.indexPathsForVisibleRows {

            // making sure each indexPath is unique
            let visibleCells = Set(listOfVisibleRows)

            // getting a reference of all indexPaths with pending operations
            let allPendingOperations = Set(pendingOperations.downloadInProgress.keys)

            // preparing to cancel all operations, except those of visible cells
            var operationsToBeCancelled = allPendingOperations

            // substracting operations of visible cells, from those waiting to be cancelled
            operationsToBeCancelled.subtract(visibleCells)

            // getting a reference of operations to be started
            var opertationsToBeStarted = visibleCells

            //  ensuring there is no pending operation within the list of indexPaths, where operations are due to be started
            opertationsToBeStarted.subtract(allPendingOperations)

            // looping through the list of operations to be cancelled, cancelling them and removing their reference from downloadInProgress
            for operationIndexPath in operationsToBeCancelled {

                if let pendingDownload = pendingOperations.downloadInProgress[operationIndexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadInProgress.removeValue(forKey: operationIndexPath)
            }

            // looping through the list of operations to be started and starting them
            for indexPath in opertationsToBeStarted {
                let imageToBeFetched = photoDetails[indexPath.row]
                startOperations(for: imageToBeFetched, indexPath: indexPath)

            }
        }
    }
}

extension FeedsVC {
    // MARK: - Operations Management
    
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        switch (photoRecord.state) {
        case .new:
            startDownload(for: photoRecord, indexPath: indexPath)
        case .downloaded:
            print("Cache image at index:\(indexPath)")
        case .failed:
            print("Image failed")
            
        }
        
    }

    func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        imageFetching.completionBlock = {
            
            if imageFetching.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
            }
            
        }
        
        pendingOperations.downloadInProgress[indexPath] = imageFetching
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
    }
    
    func suspendOperations() {
        
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeOperations() {
        
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    
}



extension FeedsVC {
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return photoDetails.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }

        // Configure the cell...

        let record = photoDetails[indexPath.row]
        cell.tableImageView.image = record.image
        
        switch (record.state) {
       
        case .new:
            if !tableView.isDragging && !tableView.isDecelerating {
                startOperations(for: record, indexPath: indexPath)
            }
        case .downloaded:
//            tableView.reloadRows(at: [indexPath], with: .fade)
            storage.saveToCache(with: record.name as NSString, value: record as AnyObject)
            
        case .failed:
            print("Image failed to load at indexPath: \(indexPath.row)")
            // remember to add a default picture
        }
        
        return cell
    }
 

    
}

extension FeedsVC {
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - ScrollView delegate methods
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        suspendOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            loadImagesOnVisibleCells()
            resumeOperations()
        }
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        loadImagesOnVisibleCells()
        resumeOperations()
        

    }
    
    
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

    
    /*
 
     let imagecache = nSCache()
     
     then save the image to cache when you retrieve image!
 
 */
    
    
}

extension FeedsVC {
    
}
