//
//  PhotosVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit
import OAuthSwift


class PhotosVC: UICollectionViewController, OperationsManagement {

     let savedData = UserDefaults()
//     let cache = Cache()
     var userPhotoRecords: [PhotoRecord] = []
     let pendingOperations = PendingOperations()
    
    
    // Cell custoamizations
     let spacing: CGFloat = 1
     let columns: CGFloat = 3
     var cellSize: CGFloat?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        guard let savedID = savedData.object(forKey: "user_nsid") as? String else { print ("No user ID")
            return }
        let url = FlickrURLs.fetchUserPhotos(userID: savedID)
        fetchPhotoURLs(from: url!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
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
                            
                            let photoRecord = PhotoRecord(name: photo.title, imageUrl: photoURL)
                            self.userPhotoRecords.append(photoRecord)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                } catch {
                    
                    print("Error parsing JSON in PhotosVC: \(error.localizedDescription)")
                }
            case .failure(let failure):
                
                print("Authobject error: \(failure)")
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension PhotosVC {

    // MARK: - Operations Management
    
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        print("Operations started for indexPAth: \(indexPath.item)")
        switch photoRecord.state {
            
        case .new:
            startDownload(for: photoRecord, indexPath: indexPath)
        
        case .downloaded:
            print("Caching now image at indexPath: \(indexPath.item) ...")
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
//            self.cache.saveToCache(with: photoRecord.imageUrl.absoluteString as NSString, value: photoRecord.image!)
            
        case .failed:
            print("Image failed; consider showing a default image")
            
        }
            
    }
    
    func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        
        print("started downloading image at indexPath: \(indexPath.item)")
        
        guard pendingOperations.downloadInProgress[indexPath] == nil else { print("download already in progress for indexPath: \(indexPath.item)")
            return
        }
        
        let imageFetching = ImageFetcher(photo: photoRecord)
        
        pendingOperations.downloadInProgress.updateValue(imageFetching, forKey: indexPath)
        pendingOperations.downloadQueue.addOperation(imageFetching)
        
        imageFetching.completionBlock = {
            
            photoRecord.state = .downloaded
            self.pendingOperations.downloadInProgress.removeValue(forKey: indexPath)
            
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func suspendOperations() {
        print("operation suspended")
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeOperations() {
        print("operation resumed")
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    
    // MARK: - Loading images on Visible Cells
    
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



extension PhotosVC {
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return userPhotoRecords.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CustomCollectionViewCell else { print("Failed casting cell in cellForItem")
            return UICollectionViewCell() }
        
        cell.imageView.image = nil
        let currentRecord = userPhotoRecords[indexPath.item]
        
        switch (currentRecord.state) {
            
        case .new:
            startOperations(for: currentRecord, indexPath: indexPath)
        
        case .downloaded:
            print("Should fetch image from cache at indexPath: \(indexPath.item)")

//            if let imageFromCache = cache.retrieveFromCache(with: currentRecord.imageUrl.absoluteString as NSString) {
//                print("Succes fetching image from cache at indexPath: \(indexPath.item)")
//                cell.imageView.image = imageFromCache as? UIImage
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

extension PhotosVC {

    // MARK: CollectionView delegate methods

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


