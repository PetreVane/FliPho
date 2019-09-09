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

class PhotosVC: UICollectionViewController, OperationsManagement {

     let savedData = UserDefaults()
     let storage = Cache()
     var userPhotoRecords: [PhotoRecord] = []
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
    
    
     func downloadWithUrlSession(at indexPath: IndexPath) {
        URLSession.shared.dataTask(with: userPhotoRecords[indexPath.item].imageUrl) {
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
    }
}

extension PhotosVC {

    // MARK: - Operations Management
    
    func startOperations(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        <#code#>
    }
    
    func startDownload(for photoRecord: PhotoRecord, indexPath: IndexPath) {
        <#code#>
    }
    
    func suspendOperations() {
        <#code#>
    }
    
    func resumeOperations() {
        <#code#>
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
        
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

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


