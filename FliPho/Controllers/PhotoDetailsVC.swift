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
        fetchComments(for: photoRecord)
    }
    
}

    //MARK: - Networking

extension PhotoDetailsVC: JSONDecoding {
        
    func fetchComments(for photoRecord: PhotoRecord) {
        
        guard let commentsURL = FlickrURLs.fetchPhotoComments(photoID: photoRecord.photoID) else { return }
        
        let networkManager = NetworkManager()
//        print("FetchCommends method called with url: \(commentsURL.absoluteString)")
        print("======== ===================== ================ =============")
        networkManager.fetchData(from: commentsURL) { [weak self] result in
            
            switch result {
            case .failure(let error):
                print("Fetching comments for image returned with error: \(error.localizedDescription)")
                
            case .success(let data):
                let decodedData = self?.decodeJSON(model: DecodedPhotoComments.self, from: data)
                let curatedComments = self?.parseDecodedData(data: decodedData)
                photoRecord.comments = curatedComments
                print("You've got \(curatedComments?.count) comments")
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
    
    func parseDecodedData(data: Result<DecodedPhotoComments, Error>?) -> [CommentData] {
        
        var comments: [CommentData] = []
        
        switch data {
            
        case .failure(let error):
            print("Errors while decoding: \(error.localizedDescription)")
            
        case .success(let decodedComments):
            let commentsList = decodedComments.comments.comment
            _ = commentsList.compactMap { commentRecord in
                
                let unixTime = commentRecord.datecreate
                guard let decodedDate = decodeDatefrom(unixTime) else { print("No comments for this image"); return }
                let comment = CommentData(id: commentRecord.id, authorNSID: commentRecord.author, authorName: commentRecord.authorname, iconServer: commentRecord.iconserver, iconFarm: commentRecord.iconfarm, commentDate: decodedDate, commentContent: commentRecord.content)
                if let curatedComment = cleanContent(of: comment) {
                    comments.append(curatedComment)
                }
            }
            
        case .none:
            print("No data to be decoded")
        }
        
        return comments
    }
    
    //MARK: - Text Operations
    
    func decodeDatefrom(_ unixTime: String) -> String? {
        
        // converts comment date into meaningful date
        
        var decodedDate: String?
        
        if let unixTime = Double(unixTime) {
            let dateFormatter = DateFormatter()
            let date = Date(timeIntervalSince1970: unixTime)
            dateFormatter.dateFormat = "dd.MM.yyyy"
            decodedDate = dateFormatter.string(from: date)
        }
        return decodedDate
    }
    
    func cleanContent(of comment: CommentData) -> CommentData? {
        
        // removes tags and references from comments
        
        var content = comment.content
        
        if content.contains("[") && content.contains("]") {
            
            guard let openingBraketIndex = content.firstIndex(of: "[") else { return nil }
            guard let closingBraketIndex = content.lastIndex(of: "]") else { return nil }
            let _ = content.removeSubrange(openingBraketIndex...closingBraketIndex)
            
        } else if content.contains("<") && content.contains(">") {
    
            guard let firstTagIndex = content.firstIndex(of: "<") else { return nil }
            guard let lastTagIndex = content.lastIndex(of: ">") else { return nil }
            let _ = content.removeSubrange(firstTagIndex...lastTagIndex)
        }
        
        if !content.isEmpty {
            let curatedContent = content
            comment.content = curatedContent
        }

        return comment
    }
    
    func timeDuration(for operation: () ->Void) -> TimeInterval {
        
        // measures how much time an operation / function needs for completion
        let operationStartingTime = Date()
        operation()
        return Date().timeIntervalSince(operationStartingTime)
    }
}


//MARK: - Scroll View Delegate

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
