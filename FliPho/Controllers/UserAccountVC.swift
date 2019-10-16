//
//  UserAccountVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

// MARK: - Variables & outlets


class UserAccountVC: UIViewController {

    fileprivate let userDefaults = UserDefaults.standard
    fileprivate let userDefaultsKeys = ["oauth_token", "oauth_token_secret", "fullname", "user_nsid", "username"]
    fileprivate let networkManager = NetworkManager()
    fileprivate var photoRecords: [PhotoRecord] = []
    fileprivate let pendingOperations = PendingOperations()
    
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var userNameContainer: UIView!
    @IBOutlet weak var realNameContainer: UIView!
    @IBOutlet weak var logOutButtonContainer: UIView!
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var realNameLabel: UILabel!

    
    // MARK: - ViewDidLoad
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchUserInfo()
        showUserDetails()
        // consider adding errorHandling

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
     // MARK: - Show User Details
    
    
    func showUserDetails() {
        
        guard let name = userDefaults.object(forKey: "fullname") as? String else { print("No name in User Defults"); return }
        guard let userName = userDefaults.object(forKey: "username") as? String else { print("No userName in User Defaults"); return }
        
        DispatchQueue.main.async {
            self.realNameLabel.text = "Hello \(name)!"
            self.userNameLabel.text = "You are logged in as: \(userName)"
        }
    }
    
    
    // MARK: - Logging Out
    
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        
        userLogOut()
    }
    
    
    func userLogOut() {
        
        for key in userDefaultsKeys {
            userDefaults.removeObject(forKey: key)
//            print("Value for key \(key) removed from User Defaults")
        }
        
        performSegue(withIdentifier: "logout", sender: nil)
    }

    // MARK: - Networking
    
    
    func fetchUserInfo() {
        guard let id = userDefaults.value(forKey: "user_nsid") as? String else { print("No user with this id"); return }
        guard let url = FlickrURLs.fetchUserInfo(userID: id) else { return }
        
        networkManager.fetchData(from: url) { result in
            
            switch result {
                
            case .failure(let error):
                print("FetchUserInfo completed with error: \(error.localizedDescription)")
                
            case .success(let userData):
                self.decodeUserInfo(from: userData)
            }
        }
    }
    
    func decodeUserInfo(from data: Data) {
        
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(DecodedUserInfo.self, from: data) else { return }
        let user = decodedData.person
        guard let userProfilePictureURL = URL(string: "http://farm\(user.iconfarm).staticflickr.com/\(user.iconserver)/buddyicons/\(user.nsid)_l.jpg") else { return }
        let photoRecord = PhotoRecord(title: user.nsid, imageUrl: userProfilePictureURL, photoID: user.id)
        fetchUserImage(record: photoRecord)
        
    }
    
    func fetchUserImage(record: PhotoRecord) {
        
        let imageFetcher = ImageFetcher(photo: record)
        pendingOperations.downloadQueue.addOperation(imageFetcher)
        
        imageFetcher.completionBlock = {
            
            self.photoRecords.append(record)
            
            DispatchQueue.main.async {
                self.imageView.image = record.image
            }
        }
    }
    
    
}
        

    

