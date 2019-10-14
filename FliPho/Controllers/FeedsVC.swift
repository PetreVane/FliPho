//
//  FeedsVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

 // MARK: - Variables


class FeedsVC: UITableViewController {

    fileprivate var photoRecords: [PhotoRecord] = []
    fileprivate var pendingOperations = PendingOperations()
//    fileprivate let cache = Cache()
    fileprivate let networkManager = NetworkManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flickrURL = FlickrURLs.fetchInterestingPhotos()
        fetchImageURLs(from: flickrURL)
    }
    
}

 // MARK: - Networking


extension FeedsVC: JSONDecoding {
        
    func fetchImageURLs(from url: URL?) {
        guard let flickrUrl = url else { return }
        
        networkManager.fetchData(from: flickrUrl) { [weak self] (result) in
            
            switch result {
                
            case .success(let receivedData):
               
                if let decodedData = self?.decodeJSON(model: DecodedPhotos.self, from: receivedData) {
                    self?.parseResults(from: decodedData)
                }
                
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(with: error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: - Parsing JSON
    
    func decodeJSON<T>(model: T.Type, from data: Data) -> Result<T, Error> where T : Decodable {

        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(model.self, from: data)
            return .success(decodedData)
            
        } catch let error {
            return .failure(error)
        }
    }
    
    func parseResults<T>(from decodedData:  Result<T, Error>) {
        
        switch decodedData {

        case .success(let photos as DecodedPhotos):
            let album = photos.photos.photo
            _ = album.compactMap { photo in
                if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_z.jpg") {
                    let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                    self.photoRecords.append(photoRecord)
                }
            }
            
            
        case .failure(let error):
            showAlert(with: error.localizedDescription)
            
        case .success(_):
            print(" --> xcode bug <-- ")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Alert

    func showAlert(with errorMessage: String) {
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - Operations Management


extension FeedsVC: OperationsManagement {

     func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {

        if photoRecord.state == .new {
            startDownload(for: photoRecord, indexPath: indexPath)
        }
//        switch (photoRecord.state) {
//
//        case .new:
//            startDownload(for: photoRecord, indexPath: indexPath)
//
//        case .downloaded:
//            if cache.retrieveFromCache(with: photoRecord.imageUrl.absoluteString as NSString) == nil {
//
//                print("Fetched at indexPath: \(indexPath.row);  Caching now ...")
////                cache.saveToCache(with: photoRecord.imageUrl.absoluteString as NSString, value: photoRecord.image!)
//
//            } else {
//                print("Image at \(indexPath.row) is already in cache")
//            }
//
//        case .failed:
//            print("Image failed")
//            // show a default image
//        }
    }

     func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
//        print("Image url: \(photoRecord.imageUrl.absoluteString)")
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        pendingOperations.downloadInProgress.updateValue(imageFetching, forKey: indexPath)
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
        
        imageFetching.completionBlock = {
            
            if imageFetching.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
     func suspendOperations() {
        
        pendingOperations.downloadQueue.isSuspended = true
    }
    
     func resumeOperations() {
        
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    // MARK: - Loading images on Visible Cells
    
    
    func loadImagesOnVisibleRows() {
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
            var operationsToBeStarted = visibleCells
            
            //  ensuring there is no pending operation within the list of indexPaths, where operations are due to be started
            operationsToBeStarted.subtract(allPendingOperations)
            
            // looping through the list of operations to be cancelled, cancelling them and removing their reference from downloadInProgress
            for indexPath in operationsToBeCancelled {
                
                if let pendingDownload = pendingOperations.downloadInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
                // unloads from memory images that are no longer visible
                photoRecords[indexPath.row].image = nil
                photoRecords[indexPath.row].state = .new
            }
            
            // looping through the list of operations to be started and starting them
            for indexPath in operationsToBeStarted {
                let imageToBeFetched = photoRecords[indexPath.row]
                startOperations(for: imageToBeFetched, indexPath: indexPath)
            }
        }
    }
}


 // MARK: - Table view data source


extension FeedsVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return photoRecords.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }

        // Configure the cell...

        let currentRecord = photoRecords[indexPath.row]
        
        switch currentRecord.state {

        case .new:
            if !tableView.isDragging && !tableView.isDecelerating {
                startOperations(for: currentRecord, indexPath: indexPath)
            }
        case .downloaded:
            if !tableView.isDragging && !tableView.isDecelerating {
                
                 }
//            if let imageFromCache = cache.retrieveFromCache(with: currentRecord.imageUrl.absoluteString as NSString) {
//                print(" ")
//                if !tableView.isDragging && !tableView.isDecelerating {
//                    cell.tableImageView.image = imageFromCache as? UIImage
//                    print("Success showing image from cache for indexPath: \(indexPath.row)")
//                }
//            }

        case .failed:
            print("Image failed to load at indexPath")
            // remember to add a default picture
        }
        
        cell.tableImageView.image = currentRecord.image
      
        return cell
    }
}

// MARK: - Table view delegate methods


extension FeedsVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
                
    }

    
    // MARK: - ScrollView delegate methods
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        suspendOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            loadImagesOnVisibleRows()
            resumeOperations()
        }
    }
    
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        loadImagesOnVisibleRows()
        resumeOperations()

    }
}


    
    // MARK: - Navigation
       
extension FeedsVC {
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let destinationVC = segue.destination as? PhotoDetailsVC else { return }
        let rowImage = photoRecords[indexPath.row].image
        
        if segue.identifier == feedImageDetails {
       
            destinationVC.selectedImage = rowImage
        }
    }
}
