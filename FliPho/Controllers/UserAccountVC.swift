//
//  UserAccountVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

class UserAccountVC: UIViewController {

    fileprivate let userDefaults = UserDefaults.standard
    fileprivate let userDefaultsKeys = ["oauth_token", "oauth_token_secret", "fullname", "user_nsid", "username"]
    
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var userNameContainer: UIView!
    @IBOutlet weak var realNameContainer: UIView!
    @IBOutlet weak var logOutButtonContainer: UIView!
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var realNameLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchUserInfo()
        showUserDetails()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    func showUserDetails() {
        
        guard let name = userDefaults.object(forKey: "fullname") as? String else { print("No name in User Defults"); return }
        guard let userName = userDefaults.object(forKey: "username") as? String else { print("No userName in User Defaults"); return }
        DispatchQueue.main.async {
            self.realNameLabel.text = "Hello \(name)!"
            self.userNameLabel.text = "You are logged in as: \(userName)"
        }
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        
        userLogOut()
    }
    
    
    func userLogOut() {
        
        for key in userDefaultsKeys {
            userDefaults.removeObject(forKey: key)
            print("Value for key \(key) removed from User Defaults")
        }
        
        performSegue(withIdentifier: "logout", sender: nil)
    }

    
    func fetchUserInfo() {
        guard let id = userDefaults.value(forKey: "user_nsid") as? String else { print("No user with this id"); return }
        guard let url = FlickrURLs.fetchUserInfo(userID: id) else { return }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { return }
            
            guard let serverResponse = response as? HTTPURLResponse,
                serverResponse.statusCode == 200 else { return }
            
            guard let receivedData = data else { return }
            
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(JSON.EncodedUserInfo.self, from: receivedData)
                let decodedInfo = decodedData.person
                
//                print("Icon farm: \(decodedInfo.iconfarm), icon server: \(decodedInfo.iconserver), nsid: \(decodedInfo.nsid)")
                guard let profilePictUrl = URL(string: "http://farm\(decodedInfo.iconfarm).staticflickr.com/\(decodedInfo.iconserver)/buddyicons/\(decodedInfo.nsid)_l.jpg") else { return }
                
                let privateQueue = DispatchQueue.global(qos: .utility)
                
                privateQueue.async {
                    guard let imageData = try? Data(contentsOf: profilePictUrl) else { return }
                    let image = UIImage(data: imageData)
                    
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
                
                
            } catch let error {
                print("Errors in fetchUserInfo: \(error.localizedDescription)")
            }
            
        }
        task.resume()
    }
    
    
    
    
    
}
