//
//  PhotosVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit
import OAuthSwift



//MARK: - Variables


class PhotosVC: UICollectionViewController, OperationsManagement {

    fileprivate let userDefaults = UserDefaults()
    fileprivate let cache = Cache()
    fileprivate var userPhotoRecords: [PhotoRecord] = []
    fileprivate let pendingOperations = PendingOperations()
    fileprivate let networkManager = NetworkManager()
    
    
    // Cell custoamizations
     let spacing: CGFloat = 1
     let columns: CGFloat = 3
     var cellSize: CGFloat?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPhotosURL = retrieveUserID(from: userDefaults)
        fetchPhotoURLs(from: userPhotosURL)
    }
    

}


    
    // MARK: - Networking
    
extension PhotosVC: JSONDecoding {
        
    func retrieveUserID(from userDefaults: UserDefaults) -> URL? {
                
        guard let savedID = userDefaults.object(forKey: "user_nsid") as? String else { print ("No user ID"); return nil}
        guard let url = FlickrURLs.fetchUserPhotos(userID: savedID) else { return nil }
        
        return url
    }
    
    func fetchPhotoURLs(from url: URL?) {
        
        guard let userPhotosURL = url else { return }

        networkManager.fetchData(from: userPhotosURL) { [weak self] (result) in
            
            switch result {
                
            case .failure(let error):
                self?.showAlert(with: error.localizedDescription)
                
            case .success(let data):
                if let decodedData = self?.decodeJSON(model: DecodedPhotos.self, from: data) {
                    self?.parseData(from: decodedData)
                }
                
            }
        }
    }
    
  //MARK: - Json decoding & Parsing
    
    func decodeJSON<T>(model: T.Type, from data: Data) -> Result<T, Error> where T : Decodable {
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(model, from: data)
            return .success(decodedData)
            
        } catch let error {
            return .failure(error)
        }
    }
    
    func parseData<T>(from data: Result<T, Error> ) {
        
        switch data {
        case .failure(let error):
            print("errors enountered while decoding: \(error.localizedDescription)")
            
        case .success(let photos as DecodedPhotos):
            
            let userAlbum = photos.photos.photo
            _ = userAlbum.compactMap { photo in
                if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
                    let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                    self.userPhotoRecords.append(photoRecord)
                }
            }
        case .success(_):
            print(" --> xcode bug <--")
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
 // MARK: - Alert
    
    func showAlert(with message: String) {
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(action)
        present(self, animated: true, completion: nil)
    }
}

// MARK: - Operations Management

    
extension PhotosVC {
    
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        if photoRecord.state == .new {
            startDownload(for: photoRecord, indexPath: indexPath)
        }
       
//        switch photoRecord.state {
//
//        case .new:
//            startDownload(for: photoRecord, indexPath: indexPath)
//
//        case .downloaded:
//            if cache.retrieveFromCache(with: photoRecord.imageUrl.absoluteString as NSString) == nil {
//
////                print("Downloaded image at index \(indexPath.item) not cached yet. Caching now ...")
//                cache.saveToCache(with: photoRecord.imageUrl.absoluteString as NSString, value: photoRecord.image!)
//
//            } else {
////                print("Image at \(indexPath.item) cached already")
//            }
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadItems(at: [indexPath])
//            }
//
//        case .failed:
//            print("Image failed; consider showing a default image")
//
//        }
            
    }
    
    func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
                
        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        pendingOperations.downloadInProgress.updateValue(imageFetching, forKey: indexPath)
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
        imageFetching.completionBlock = {
            
            
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func suspendOperations() {

        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeOperations() {

        pendingOperations.downloadQueue.isSuspended = false
    }
    
    
    // MARK: - Loading images
    
    
    func loadImagesOnVisibleItems() {
    
        // getting a reference of all visible rows
            let listOfVisibleItems = collectionView.indexPathsForVisibleItems
            
            // making sure each indexPath is unique
            let visibleItems = Set(listOfVisibleItems)
            
            // getting a reference of all indexPaths with pending operations
            let allPendingOperations = Set(pendingOperations.downloadInProgress.keys)
            
            // preparing to cancel all operations, except those of visible cells
            var operationsToBeCancelled = allPendingOperations
            
            // substracting operations of visible cells, from those waiting to be cancelled
            operationsToBeCancelled.subtract(visibleItems)
            
            // getting a reference of operations to be started
            var operationsToBeStarted = visibleItems
            
            //  ensuring there is no pending operation within the list of indexPaths, where operations are due to be started
            operationsToBeStarted.subtract(allPendingOperations)
            
            // looping through the list of operations to be cancelled, cancelling them and removing their reference from downloadInProgress
            for indexPath in operationsToBeCancelled {
                
                if let pendingDownload = pendingOperations.downloadInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
                userPhotoRecords[indexPath.row].image = nil
                userPhotoRecords[indexPath.row].state = .new
            }
            
            // looping through the list of operations to be started and starting them
            for indexPath in operationsToBeStarted {
                let imageToBeFetched = userPhotoRecords[indexPath.item]
                startOperations(for: imageToBeFetched, indexPath: indexPath)
                
            }
        }
    
    }


// MARK: - Data Source


extension PhotosVC {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return userPhotoRecords.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else { return UICollectionViewCell() }
        
        let currentRecord = userPhotoRecords[indexPath.item]
        
        switch (currentRecord.state) {
            
        case .new:
            if !collectionView.isDragging && !collectionView.isDecelerating {
                startOperations(for: currentRecord, indexPath: indexPath)
            }
            
        
        case .downloaded:
            if !collectionView.isDragging && !collectionView.isDecelerating {
                
             }
//            print("Image downloaded at indexPath: \(indexPath.item)")
//            if let imageFromCache = cache.retrieveFromCache(with: currentRecord.imageUrl.absoluteString as NSString) {
//                if !collectionView.isDragging && !collectionView.isDecelerating {
//                    cell.imageView.image = imageFromCache as? UIImage
////                    print("Succces showing image from cache at indexPath \(indexPath.item)")
//                }
//            }
            
        case .failed:
            
            print("Image failed; showing default image")
        }
        
        cell.imageView.image = currentRecord.image

        return cell
    }

}


extension PhotosVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cellSize == nil {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (columns * spacing - 1)
            cellSize = (view.frame.size.width - emptySpace) / columns
        }

        return CGSize(width: cellSize!, height: cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

}


// MARK:- Delegate methods


extension PhotosVC {

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendOperations()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if !decelerate {
            loadImagesOnVisibleItems()
            resumeOperations()
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        loadImagesOnVisibleItems()
        resumeOperations()
    }
    
}

 // MARK: - Navigation


extension PhotosVC {
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        guard let indexPaths = collectionView.indexPathsForSelectedItems else { return }
        guard let destinationVC = segue.destination as? PhotoDetailsVC else { return }
        guard let indexPath = indexPaths.first else { return }
        let cellImage = userPhotoRecords[indexPath.item].image
        
        if segue.identifier == userImageDetails {
            destinationVC.selectedImage = cellImage
            
        }
    }
}


