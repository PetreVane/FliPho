//
//  LoginVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit
import Foundation
import OAuthSwift

 // MARK: - Variables


class LoginVC: UIViewController {
    
    fileprivate let userDefaults = UserDefaults.standard
    fileprivate let callBackURL = URL(string: "FliPho://")
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
                
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        askForAuthorization()

    }
    
    
    @IBAction func newAccountButtonPressed(_ sender: UIButton) {
        
        if let url =  URL(string: "https://identity.flickr.com/sign-up") {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
    
   // MARK: - Networking

    
    func askForAuthorization() {
        
       let authObject = OAuth1Swift( consumerKey: consumerKey, consumerSecret: consumerSecret,
                                        requestTokenUrl: requestTokenURL,
                                        authorizeUrl: authorizationURL,
                                        accessTokenUrl: accessTokenURL)
        
        authObject.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: authObject)
        
        _ =  authObject.authorize(withCallbackURL: callBackURL!) { (result) in
            
            switch result {
            case .success(let (_, _, parameters)):
                for (key, _) in parameters {
                    if let valueAsString = parameters[key] as? String {
//                        print("Value as string: \(valueAsString.removingPercentEncoding)")
                        self.userDefaults.set(valueAsString.removingPercentEncoding, forKey: key)
                        self.userDefaults.set(true, forKey: "loggedIn")
                    }
                }
                self.authenticate(with: authObject)
            case .failure(let error):
//                print("Authentication process ended with error: \(error.description)")
                self.showAlert(with: "Make sure you're connected to internet")
            }
        }
    }
    

    func authenticate(with oauthswift: OAuth1Swift) {
       
        let savedUserID = userDefaults.value(forKey: "user_nsid")
        let authenticationUrl = FlickrURLs.checkAuthToken(userID: savedUserID as! String)
        
        _ = oauthswift.client.get(authenticationUrl!) { response in
        
            switch response {
                case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "mainMenu", sender: nil)
//                    print("Authentication successful")
                }
            case .failure(let error):
//                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert(with: "Authentication: something went wrong")
                }
            }
        }
    }

     // MARK: - Alert
    
    
    func showAlert(with errorMessage: String) {
        
        let alert = UIAlertController(title: "Couldn't sign you in", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
