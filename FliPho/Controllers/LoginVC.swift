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
        
       let authObject = OAuth1Swift( consumerKey: consumerKey, consumerSecret: consumerSecret,
                                        requestTokenUrl: requestTokenURL,
                                        authorizeUrl: authorizationURL,
                                        accessTokenUrl: accessTokenURL)
        
        authObject.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: authObject)
       
        _ =  authObject.authorize(withCallbackURL: callBackURL!) { (result) in
            
            switch result {
            case .success(let (_, _, parameters)):
                print("Auth returned: \(parameters)")
                for (key, value) in parameters {
                    self.defaults.set(value, forKey: key)
                }
                self.authenticate(with: authObject)
                
            case .failure(let error):
                print("Authentication process ended with error: \(error.description)")
                self.showAlert(with: "Make sure you're connected to internet")
            }
            
        }
    }
    

    func authenticate(with oauthswift: OAuth1Swift) {
       
        // come back and change this method
        let url = Flickr.apiEndPoint(where: APIMethod.isCheckOauthToken)
        
        _ = oauthswift.client.get(url) { response in
        
            switch response {
                
            case .success:
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "mainMenu", sender: nil)
//                    print("Authentication successful")
                }
            case .failure(let error):
                
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert(with: "Authentication: something went wrong")
                }
                
            }
            
        }
    }

    func showAlert(with errorMessage: String) {
        
        let alert = UIAlertController(title: "Couldn't sign you in", message: errorMessage, preferredStyle: .alert)
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
