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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let userName = userDefaults.object(forKey: "username" as String) {
            print("Your username is: \(userName)")
        } else {
            print("no key with this name")
        }
        
//        if let userLoggedIn = userDefaults.object(forKey: "loggedIn") as? Bool {
//            print("User is logged in: \(userLoggedIn)")
//        }
        
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

}
