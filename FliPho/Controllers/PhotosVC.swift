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
    fileprivate let endpointURL = URL(string: Flickr.apiEndPoint(where: APIMethod.isGetPhotos))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(endpointURL)
        fetchUserPhotos(from: endpointURL!)
        
    }

}

extension PhotosVC {
    
    // MARK: - Networking

    func fetchUserPhotos(from url: URL) {
        
        let jsonDecoder = JSONDecoder()
        
        let authObject = OAuthSwiftClient(consumerKey: Constants.consumerKey, consumerSecret: Constants.consumerSecret, oauthToken: savedData.value(forKey: "oauth_token") as! String, oauthTokenSecret: savedData.value(forKey: "oauth_token_secret") as! String, version: .oauth1)
        
        
        authObject.get(url) { (result) in
            
            print(authObject.description)
            
            switch result {
            case .success(let success):
//                print("AuthObject success: \(success.dataString(encoding: .utf8))")
                do {
                    let decodedData = try jsonDecoder.decode(EncodedJSON.self, from: success.data)
                    let decodedPhotos = decodedData.photos.photo
                    print("You've got \(decodedPhotos.count) images")
                    
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
        
//        do {
////            let decodedData = try jsonDecoder.decode(EncodedJSON.self, from: )
//
//        } catch {
//            print("Error parsing JSON in PhotosVC: \(error.localizedDescription)")
//        }

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        DispatchQueue.main.async {
            if let cell = collectionView.cellForItem(at: indexPath) {
                
            }
        }
        
    
        return cell
    }

}


extension PhotosVC {
    // MARK: UICollectionViewDelegate

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
