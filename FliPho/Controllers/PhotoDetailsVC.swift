//
//  PhotoDetailsVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

class PhotoDetailsVC: UIViewController {
    
    weak var delegatedPhotoRecord: PhotoRecord?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegation
        scrollView.delegate = self
        guard let photoRecord = delegatedPhotoRecord else { print("No photoRecord passed to PhotoDetails ViewController"); return }
        imageView.image = photoRecord.image
        
        
                    
        // scrollView methods
        zoomParameters(scrollView.bounds.size)
        centerImage()
        
        // networking
        guard let commentsURL = FlickrURLs.fetchPhotoComments(photoID: photoRecord.photoID) else { return }
        fetchCommentsFrom(commentsURL)
    }
    
}

    //MARK: - Networking

extension PhotoDetailsVC: JSONDecoding {
        
    func fetchCommentsFrom(_ commentsURL: URL ) {
        
        let networkManager = NetworkManager()
        print("FetchCommends method called with url: \(commentsURL.absoluteString)")
        
        networkManager.fetchData(from: commentsURL) { [weak self] result in
            
            switch result {
            case .failure(let error):
                print("Fetching comments for image returned with error: \(error.localizedDescription)")
                
            case .success(let data):
                let decodedData = self?.decodeJSON(model: DecodedPhotoComments.self, from: data)
                self?.parseDecodedData(data: decodedData)
            }
        }
    }
    
    func decodeJSON<T>(model: T.Type, from data: Data) -> Result<T, Error> where T : Decodable {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let decodedData = try decoder.decode(model.self, from: data)
            return .success(decodedData)

        } catch let error {
            return .failure(error)
        }
    }
    
    func parseDecodedData(data: Result<DecodedPhotoComments, Error>?) {
        
        switch data {
            
        case .failure(let error):
            print("Errors while decoding: \(error.localizedDescription)")
            
        case .success(let decodedComments):
            let commentsList = decodedComments.comments.comment
            _ = commentsList.compactMap { comment in
                let unixTime = comment.datecreate
                guard let decodedDate = decodeDatefrom(unixTime) else {print("No comments for this image"); return }
                print("Comment added on: \(decodedDate)")
                
            }
            
        case .none:
            print("No data to be decoded")
        }
    }
    
    func decodeDatefrom(_ unixTime: String) -> String? {
        
        var decodedDate: String?
        
        if let unixTime = Double(unixTime) {
            let dateFormatter = DateFormatter()
            let date = Date(timeIntervalSince1970: unixTime)
            dateFormatter.dateFormat = "dd.MM.yyyy"
            decodedDate = dateFormatter.string(from: date)
        }
        return decodedDate
    }
    
    
}



extension PhotoDetailsVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    

    
    /// Configures the zoom scale
    /// - Parameter scrollViewSize: accepts the size of the scrollView bounds, as argument
    func zoomParameters(_ scrollViewSize: CGSize) {
        
        // gets the size of the image
        let imageSize = imageView.bounds.size
        
        // divides the scrollView size to ImageView size, and gets the minimum value
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        //sets the minimum value as starting zoom scale & minimum zoom scale
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3
        scrollView.zoomScale = 1
    }
    
    
    /// Centers back the image when user Stops zooming out, so the image won't remain zoomed out
    func centerImage() {
        
        // gets the scrollView & imageView size
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
    /*
        If the imageView size is smaller than the scrollView size, then substracts the size of the image from the size of the scrollView, and then divides the difference by 2.
         Then this value (the difference) is set as distance (Insets) between the scrollView and image
    */
        let horizontalSpace = imageViewSize.width < imageViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        let verticalSpace = imageViewSize.height < imageViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        
        // sets the UIInsets values
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
        
    }
    
}
