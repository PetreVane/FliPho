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

     fileprivate let savedData = UserDefaults()
     fileprivate let cache = Cache()
     fileprivate var userPhotoRecords: [PhotoRecord] = []
     fileprivate let pendingOperations = PendingOperations()
    
    
    // Cell custoamizations
     let spacing: CGFloat = 1
     let columns: CGFloat = 3
     var cellSize: CGFloat?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let savedID = savedData.object(forKey: "user_nsid") as? String else { print ("No user ID"); return }
        let url = FlickrURLs.fetchUserPhotos(userID: savedID)
        fetchPhotoURLs(from: url!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }

    
    // MARK: - Networking
    

    func fetchPhotoURLs(from url: URL) {
        
        let jsonDecoder = JSONDecoder()
        
        
        let authObject = OAuthSwiftClient(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: savedData.value(forKey: "oauth_token") as! String, oauthTokenSecret: savedData.value(forKey: "oauth_token_secret") as! String, version: .oauth1)
        
        authObject.get(url) { result in
            
            switch result {
                
            case .success(let response):

                do {
                    
                    let decodedData = try jsonDecoder.decode(DecodedPhotos.self, from: response.data)
                    let decodedPhotos = decodedData.photos.photo
            
                    for photo in decodedPhotos {
                        
                        if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
                            
                            let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                            self.userPhotoRecords.append(photoRecord)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                } catch {
                    
//                    print("Error parsing JSON in PhotosVC: \(error.localizedDescription)")
                }
            case .failure( _):
                
                print("Authobject error")
            }
        }
    }
    
    // example of using generics and result type
//    func decodeJSON<Type>(from data: Data, decodingModel: Type) -> Result<[JSON.Photos.Photo], Error> {
//
//        let decoder = JSONDecoder()
//        let jsonModel: JSON.EncodedPhotos.Type = decodingModel as! JSON.EncodedPhotos.Type
//        var listOfPhotos: [JSON.Photos.Photo] = []
//
//
//        do {
//            let decodedData = try decoder.decode(jsonModel, from: data)
//            let decodedMedia = decodedData.photos.photo
//            listOfPhotos = decodedMedia
//
//        } catch {
//
//             print("Errors while parsing Json: \(error.localizedDescription)")
//        }
//
//        return .success(listOfPhotos)
//
//    }
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
                
        guard pendingOperations.downloadInProgress[indexPath] == nil else { //print("download already in progress for indexPath")
            return
        }
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        pendingOperations.downloadInProgress.updateValue(imageFetching, forKey: indexPath)
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
        imageFetching.completionBlock = {
            
            
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
//            self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
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
            for operationIndexPath in operationsToBeCancelled {
                
                if let pendingDownload = pendingOperations.downloadInProgress[operationIndexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadInProgress.removeValue(forKey: operationIndexPath)
            }
            
            // looping through the list of operations to be started and starting them
            for indexPath in operationsToBeStarted {
                let imageToBeFetched = userPhotoRecords[indexPath.item]
                startOperations(for: imageToBeFetched, indexPath: indexPath)
                
            }
        }
    }


// MARK: Data Source


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
            startOperations(for: currentRecord, indexPath: indexPath)
        
        case .downloaded:
            if let imageFromCache = cache.retrieveFromCache(with: currentRecord.imageUrl.absoluteString as NSString) {
                if !collectionView.isDragging && !collectionView.isDecelerating {
                    cell.imageView.image = imageFromCache as? UIImage
//                    print("Succces showing image from cache at indexPath \(indexPath.item)")
                }
            }
            
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
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        userPhotoRecords[indexPath.item].image = nil
        userPhotoRecords[indexPath.item].state = .new
    }
}

 // MARK: - Navigation


extension PhotosVC {
    
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}


