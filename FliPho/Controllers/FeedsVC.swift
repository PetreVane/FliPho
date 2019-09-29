//
//  FeedsVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

 // MARK: - Variables


class FeedsVC: UITableViewController, OperationsManagement {

    fileprivate var cachedImages: [UIImage] = []
    fileprivate var photoRecords: [PhotoRecord] = []
    fileprivate var pendingOperations = PendingOperations()
    let networkManager = NetworkManager()
    let flickrURL = FlickrURLs.fetchInterestingPhotos()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchImageURLs(from: flickrURL)
    }
}

//MARK: - FileSystem methods

extension FeedsVC {
    
//    func getLocationOfFiles() {
//
//        let fileManager = FileManager.default
//
//        guard let cacheURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {print("Failed fetching cache url"); return }
//         print("Cache url: \(cacheURL)")
//
//        let temporaryDir = fileManager.temporaryDirectory
//        print("User temporary directory: \(temporaryDir)")
//
//        let documentDir = fileManager.urls(for: .allLibrariesDirectory, in: .userDomainMask)[0]
//        print("Document dir: \(documentDir)")
//
//        }

//    func removeFromDir() {
//        let cacheReference = ImageCacher()
//
//            do {
//                try cacheReference.removeItems(from: .temporaryDirectory)
//
//            } catch {
//                print("Errors while deleting items: \(error.localizedDescription)")
//            }
//        }

//    func fetchItems() {
//
//        let cacheReference = ImageCacher()
//        cacheReference.fetchItems(from: .temporaryDirectory)
//    }
    
}

 // MARK: - Networking

extension FeedsVC {
    
    func fetchImageURLs(from url: URL?) {
        
        guard let flickrUrl = url else { return }
        
        networkManager.fetchData(from: flickrUrl) { (data, error) in
            
            guard error == nil else { DispatchQueue.main.async { self.showAlert(with: error!.localizedDescription) }; return }
            
            guard let receivedData = data else { return }
            self.parseData(from: receivedData)

        }
    }
    
    
    // MARK: - Parsing JSON
    
    
    func parseData(from data: Data) {
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(JSON.EncodedPhotos.self, from: data)
            let decodedPhotos = decodedData.photos.photo
                           
               for photo in decodedPhotos {
                   
                   if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
                        let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                        self.photoRecords.append(photoRecord)
//                        self.photoURLs.append(photoURL)
                   }
               }
                   
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
            
        } catch {
//            print("Errors while parsing data: \(error.localizedDescription)")
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


extension FeedsVC {

     func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        if photoRecord.state == .new {
            startDownload(for: photoRecord, indexPath: indexPath)
        }
//        if photoRecord.state == .downloaded {
//            startCaching(record: photoRecord, at: indexPath)
//        }

//        switch (photoRecord.state) {
//
//        case .new:
//            startDownload(for: photoRecord, indexPath: indexPath)
//
//        case .downloaded:
////            startCaching(record: photoRecord, at: indexPath)
//            print("Should have started caching at indexPath: \(indexPath.row)")
//
//        case .cached:
//            print("Could release image from memory at indexPath: \(indexPath.row)")
////            photoRecords[indexPath.row].image = nil
//
//        case .failed:
//            print("Image failed")
//            // show a default image
//        }
    }

     func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        pendingOperations.downloadInProgress.updateValue(imageFetching, forKey: indexPath)
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
        
        imageFetching.completionBlock = {
                        
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                
            }
        }
    }
    
//    func startCaching(record: PhotoRecord, at indexPath: IndexPath) {
//
//        guard pendingOperations.cachingInProgress[indexPath] == nil else { return }
//        let imageCaching = ImageCacher(photoRecord: record)
//        imageCaching.saveImageToCache(record: record, key: record.imageUrl.absoluteString)
//        pendingOperations.cachingInProgress.updateValue(imageCaching, forKey: indexPath)
//        pendingOperations.cachingQueue.addOperation(imageCaching)
//
//        imageCaching.completionBlock = {
//            print("Cached image \(record.name) at indexPath: \(indexPath.row)")
//            record.state = .cached
//        }
//
//    }
        
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
            for operationIndexPath in operationsToBeCancelled {
                
                if let pendingDownload = pendingOperations.downloadInProgress[operationIndexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadInProgress.removeValue(forKey: operationIndexPath)
            }
            
            // looping through the list of operations to be started and starting them
            for indexPath in operationsToBeStarted {
                let imageToBeFetched = photoRecords[indexPath.row]
                startOperations(for: imageToBeFetched, indexPath: indexPath)
            }
        }
    }
    
    func fetchImageFromCache(record: PhotoRecord, at indexPath: IndexPath) -> UIImage? {
        guard record.state == .cached else { return nil }
        var imageFromCache: UIImage?
        let imageFetching = ImageCacher(photoRecord: record)
        DispatchQueue.main.async {
            
            if let image = imageFetching.retrieveFromCache(key: record.imageUrl.absoluteString) {
                imageFromCache = image
                print("Failed fetching Cache image at indexPath: \(indexPath.row) ")
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                
            } else {
                print("Failed gettinf image from cache at indexPath: \(indexPath)")
            }
//            imageFromCache = image
//            self.cachedImages.append(imageFromCache!)
//            print("You've got \(self.cachedImages.count) images")
        }
        
        return imageFromCache
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
        
        switch (currentRecord.state) {

        case .new:
            if !tableView.isDragging && !tableView.isDecelerating {
                startOperations(for: currentRecord, indexPath: indexPath)
            }
        case .downloaded:
            if !tableView.isDragging && !tableView.isDecelerating {
                
            }
            
        case .cached:
            if !tableView.isDragging && !tableView.isDecelerating {
                
//                guard let imageFromCache = fetchImageFromCache(record: currentRecord, at: indexPath) else { return UITableViewCell() }
//                cell.tableImageView.image = imageFromCache
//                print("Showing image from cache at indexPath: \(indexPath.row)")
                


            }

        case .failed:
            NSLog(String("Image Failed"))
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
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        photoRecords[indexPath.row].image = nil
        photoRecords[indexPath.row].state = .new
        
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
    
    /*
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
