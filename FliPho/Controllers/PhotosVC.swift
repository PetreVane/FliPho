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
    
    
    fileprivate let savedData = UserDefaults()
    fileprivate var userAlbum: [PhotoRecord] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let savedID = savedData.object(forKey: "user_nsid") as? String else { print("No user ID")
            return }
        // show an alert when user id cannot be retrieved

        let url = FlickrURLs.fetchUserPhotos(userID: savedID)
        fetchUserPhotos(from: url!)
    }

}

extension PhotosVC {
    
    // MARK: - Networking

    func fetchUserPhotos(from url: URL) {
        
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
                            self.userAlbum.append(photoRecord)
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
    }
    
    /*
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}

extension PhotosVC {
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return userAlbum.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CustomCollectionViewCell else { return UICollectionViewCell() }
    
        let record = userAlbum[indexPath.row]
        
//        cell.imageView.image = record.image
        
        switch record.state {
        case .new:
            print("Should start image fetching")
            
        case .downloaded:
            print("Photo record at indexPath \(indexPath.row) has been downloaded")
            
        case .failed:
            print("Photo record at indexPath \(indexPath.row) has failed")
        }
        
        DispatchQueue.main.async {
            if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
                cell.imageView.image = record.image
            }
        }
        

        return cell
    }

}


extension PhotosVC {
    // MARK: UICollectionViewDelegate

//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        
//        let indexPath = collectionView.indexPathsForVisibleItems
//        for index in indexPath {
//            DispatchQueue.main.async {
//                self.collectionView.reloadItems(at: [index])
//            }
////            collectionView.reloadItems(at: [index])
//        }
//           
//        
//    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
