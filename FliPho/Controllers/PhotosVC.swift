//
//  PhotosVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit
import OAuthSwift

private let reuseIdentifier = "collectionCell"

class PhotosVC: UICollectionViewController {
    
    
     let savedData = UserDefaults()
     let storage = Cache()
     var photoRecords: [PhotoRecord] = []
     let pendingOperations = PendingOperations()
    
    
    // Cell custoamizations
     let spacing: CGFloat = 1
     let columns: CGFloat = 3
     var cellSize: CGFloat?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        guard let savedID = savedData.object(forKey: "user_nsid") as? String else { print("No user ID")
            return }
        let url = FlickrURLs.fetchUserPhotos(userID: savedID)
        fetchPhotoURLs(from: url!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        guard let savedID = savedData.object(forKey: "user_nsid") as? String else { print("No user ID")
//            return }
//        let url = FlickrURLs.fetchUserPhotos(userID: savedID)
//        fetchPhotoURLs(from: url!)
    }



//extension PhotosVC {
    
    // MARK: - Networking

    func fetchPhotoURLs(from url: URL) {
        
        let jsonDecoder = JSONDecoder()
        
        
        let authObject = OAuthSwiftClient(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: savedData.value(forKey: "oauth_token") as! String, oauthTokenSecret: savedData.value(forKey: "oauth_token_secret") as! String, version: .oauth1)
        
        authObject.get(url) { (result) in
            
            switch result {
                
            case .success(let response):

                do {
                    let decodedData = try jsonDecoder.decode(EncodedPhotos.self, from: response.data)
                    let decodedPhotos = decodedData.photos.photo
            
                    for photo in decodedPhotos {
                        if let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg") {
//                            print("PhotoURL: \(photoURL)")
                            let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                            self.photoRecords.append(photoRecord)
                            
                        }
                    }
                    
                    print("PhotosVC: fetched \(self.photoRecords.count) urls")
//                    print("URLs: \(self.photoRecords)
                    
                } catch {
                    
                    print("Error parsing JSON in PhotosVC: \(error.localizedDescription)")
                }
            case .failure(let failure):
                
                print("Authobject error: \(failure)")
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            print("reloading collection view")
        }
    }
    
    
     func downloadWithUrlSession(at indexPath: IndexPath) {
        URLSession.shared.dataTask(with: photoRecords[indexPath.item].imageUrl) {
            [weak self] data, response, error in
            
            guard let self = self,
                let data = data,
                let image = UIImage(data: data) else { print("Failed casting data as image")
                    return
            }
            
            DispatchQueue.main.async {
                if let cell = self.collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
                    cell.imageView.image = image
                    print("Assigning image to cell image")
                } else {
                    print("Failed assigning image to cell image")
                }
            }
        }.resume()
        
    
    
    
//    func fetchImageFromCache(at indexPath: IndexPath) -> UIImage? {
//
//        var cachedImage: UIImage?
//        let currentRecord = photoRecords[indexPath.row]
//        if let imageFromCache = storage.retrieveFromCache(with: currentRecord.imageUrl.absoluteString as NSString) {
//            cachedImage = imageFromCache as? UIImage
//        }
//
//        return cachedImage
//    }
    
}


//extension PhotosVC {
//
//    //MARK: - Operations Management
//
//    fileprivate func startOperations(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
//
//
//        switch photoRecord.state {
//
//        case .new:
//
//            startDownload(for: photoRecord, at: indexPath)
//
//        case .downloaded:
//
//            if storage.retrieveFromCache(with: photoRecord.imageUrl.absoluteString as NSString) != nil {
//                print("Image at indexPath: \(indexPath.row) is already in cache now")
//
//            } else {
//
//                print("This image is not cached yet. Caching now at indexPath: \(indexPath.row)")
//                storage.saveToCache(with: photoRecord.imageUrl.absoluteString as NSString, value: photoRecord.image!)
//
//            }
//
//        default:
//            print("image failed")
//        }
//
//    }
//
//    fileprivate func startDownload(for photoRecord: PhotoRecord, at indexPath: IndexPath) {
//
//        guard pendingOperations.downloadInProgress[indexPath] == nil else { return }
//
//        let imageFetching = ImageFetcher(photo: photoRecord)
//
//        pendingOperations.downloadInProgress.updateValue(imageFetching, forKey: indexPath)
//        pendingOperations.downloadQueue.addOperation(imageFetching)
//
//        imageFetching.completionBlock = {
//
//            if imageFetching.isCancelled {
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//                self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
//                print("ImageFetching completion block reached")
//            }
//            if imageFetching.isFinished {
//                print("ImageFetching in collection has completed task at indexPath: \(indexPath)")
//            }
//        }
//
//
//
//    }
//
//    fileprivate func suspendOperations() {
//        pendingOperations.downloadQueue.isSuspended = true
//    }
//
//    fileprivate func resumeOperations() {
//        pendingOperations.downloadQueue.isSuspended = false
//    }
//
//    fileprivate func showImagesOnVisibleCells() {
//
//        let indexPathsOfVisibleCells = collectionView.indexPathsForVisibleItems
//
//        // making sure each indexPath is unique
//        let visibleCells = Set(indexPathsOfVisibleCells)
//
//        // getting a reference of all indexPaths with pending operations
//        let allPendingOperations = Set(pendingOperations.downloadInProgress.keys)
//
//        // preparing to cancel all operations, except those of visible cells
//        var operationsToBeCancelled = allPendingOperations
//
//        // substracting operations of visible cells, from those waiting to be cancelled
//        operationsToBeCancelled.subtract(visibleCells)
//
//        // getting a reference of operations to be started
//        var operationsToBeStarted = visibleCells
//
//        //  ensuring there is no pending operation within the list of indexPaths, where operations are due to be started
//        operationsToBeStarted.subtract(allPendingOperations)
//
//        // looping through the list of operations to be cancelled, cancelling them and removing their reference from downloadInProgress
//        for operationIndexPath in operationsToBeCancelled {
//
//            if let pendingDownload = pendingOperations.downloadInProgress[operationIndexPath] {
//                pendingDownload.cancel()
//            }
//            pendingOperations.downloadInProgress.removeValue(forKey: operationIndexPath)
//        }
//
//        // looping through the list of operations to be started and starting them
//        for indexPath in operationsToBeStarted {
//            let imageToBeFetched = photoRecords[indexPath.row]
//            startOperations(for: imageToBeFetched, at: indexPath)
//
//        }
//
//    }
//
//}



//extension PhotosVC {
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photoRecords.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else { print("Failed casting cell in cellForItem")
            return UICollectionViewCell() }
        
//        let record = photoRecords[indexPath.item]
        
        downloadWithUrlSession(at: indexPath)
        
//        switch (record.state) {
//
//        case .new:
//            print("New record")
//            if !collectionView.isDragging && !collectionView.isDecelerating {
//                startOperations(for: record, at: indexPath)
//            }
//
//        case .downloaded:
//            print("Image downloaded")
////            if let cachedImage = fetchImageFromCache(at: indexPath) {
////                if !collectionView.isDragging && !collectionView.isDecelerating {
////                    cell.imageView.image = cachedImage
////                    print("Success fetching image from cache at indexPath: \(indexPath.row)")
////                }
////            }
//
//        default:
//            print("failed showing an image")
//            // consider showing a default image
//        }
    
//        cell.imageView.image = record.image

        return cell
    }

//}


//extension PhotosVC: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if cellSize == nil {
//            let layout = collectionViewLayout as! UICollectionViewFlowLayout
//            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (columns * spacing - 1)
//            cellSize = (view.frame.size.width - emptySpace) / columns
//        }
//
//        return CGSize(width: cellSize!, height: cellSize!)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return spacing
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return spacing
//    }
//
//}

//extension PhotosVC {
//
//    // MARK: CollectionView delegate methods
//
//    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        suspendOperations()
//    }
//
//    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//        if !decelerate {
//            resumeOperations()
//            showImagesOnVisibleCells()
//        }
//
//    }
//
//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        resumeOperations()
//        showImagesOnVisibleCells()
//    }
//}
}
extension PhotosVC {
    // MARK: - Navigation
    
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}

extension PhotosVC {
    // MARK: - Dumpster
    
    //    func fetchUserPhotos(at indexPath: IndexPath) -> IndexPath {
    //
    //
    //        var index: IndexPath = indexPath
    //        let currentRecordURL = userAlbumURLs[indexPath.row]
    //        print("Fetch user index is: \(currentRecordURL)")
    //
    //        URLSession.shared.dataTask(with: currentRecordURL) { [weak self] (data, response, error) in
    //
    //            guard error == nil,
    //                let self = self else { print( "You should show an alert with this error: \(error.debugDescription)")
    //                return }
    //
    //            guard let serverResponse = response as? HTTPURLResponse,
    //                serverResponse.statusCode == 200 else { print("You should show an alert with error /serverResponse status code")
    //                    return
    //            }
    //            guard let imageData = data,
    //            let image = UIImage(data: imageData) else { print("Could not cast data as UIImage")
    //                return }
    //
    //            DispatchQueue.main.async {
    //
    //                if let cell = self.collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
    //                    cell.imageView.image = image
    //                    self.images.append(image)
    //                    print("You've got \(self.images.count) images retrieved")
    //                } else {
    //                    print("Could not cast cell as CustomCollection cell")
    //                }
    //            }
    //        }
    //
    //        .resume()
    //        print("Your indexPath is \(index)")
    //        return index
    //    }
    
    
    
}
