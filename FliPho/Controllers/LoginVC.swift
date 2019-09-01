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

class LoginVC: UIViewController {
    
    let defaults = UserDefaults()
    let callBackURL = URL(string: "FliPho://")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if defaults.value(forKeyPath: "oauth_token") != nil {
//            print("here is your user default token: \(token as! String)")
            performSegue(withIdentifier: "mainMenu", sender: nil)
        }
        
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        askForAuthorization()
    }
    
    
    @IBAction func newAccountButtonPressed(_ sender: UIButton) {
        
        if let url =  URL(string: "https://identity.flickr.com/sign-up") {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
    
    
    

    func askForAuthorization() {
        
       let OauthObject = OAuth1Swift( consumerKey: consumerKey, consumerSecret: consumerSecret,
                                        requestTokenUrl: requestTokenURL,
                                        authorizeUrl: authorizationURL,
                                        accessTokenUrl: accessTokenURL)
        
        OauthObject.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: OauthObject)
        
        _ =  OauthObject.authorize(withCallbackURL: callBackURL!) { (result) in
            
            switch result {
            case .success(let (_, _, parameters)):
                for (key, value) in parameters {
//                    print("Each key \(key) has value \(value)")
                    self.defaults.set(value, forKey: key)
                }
//                print("Here is your token: \(parameters)")
                self.authenticate(with: OauthObject)
            
            case .failure(let error):
                print("Authentication process ended with error: \(error.description)")
                self.showAlert(with: "Make sure you're connected to internet")
            }
            
        }
    }
    

    func authenticate (with oauthswift: OAuth1Swift) {
        
        let url = Flickr.apiMethod(where: APIMethod.isInterestingPhotos)
        
        _ = oauthswift.client.get(url) { response in
        
            switch response {
            case .success:
                self.performSegue(withIdentifier: "mainMenu", sender: nil)
//                print("Response: \(response.dataString(encoding: .utf8))")
            case .failure(let error):
                print(error.localizedDescription)
                self.showAlert(with: "Username / password might be wrong")
            }
            
        }
    }

    func showAlert(with errorMessage: String) {
        
        let alert = UIAlertController(title: "Could not sign in", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
    }
     */
    
}
