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
    fileprivate var photoRecords: [PhotoRecord] = []
    var images:[UIImage] = []
    
    private let spacing: CGFloat = 1
    private let columns: CGFloat = 3
    private var cellSize: CGFloat?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let savedID = savedData.object(forKey: "user_nsid") as? String else { print("No user ID")
            return }
        // show an alert when user id cannot be retrieved

        let url = FlickrURLs.fetchUserPhotos(userID: savedID)
        fetchPhotoURLs(from: url!)
//        print("Photos Url: \(url)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        print("Photos Url: \(url)")
        
    }

}

extension PhotosVC {
    
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
                            self.photoRecords.append(photoRecord)
                        }
                    }
                    print("PhotosVC: fetched \(self.photoRecords.count) urls")
                } catch {
                    print("Error parsing JSON in PhotosVC: \(error.localizedDescription)")
                }
            case .failure(let failure):
                print("Authobject error: \(failure)")
            }
        }
    }
    
}


extension PhotosVC {
    
    //MARK: - Operations Management
    
    fileprivate func startOperations() {
        
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

extension PhotosVC {
    
    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photoRecords.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CustomCollectionViewCell else { print("Failed casting cell in cellForItem")
            return UICollectionViewCell() }
    
//        cell.imageView.image = nil
        
        DispatchQueue.main.async {
//            print("current url at index is: \(resultedIndex)")
        }
        
        
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
