//
//  LoginVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginVC: UIViewController {
    
    let callBackURL = URL(string: "FliPho://")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        authenticateUser()
    }
    

    func authenticateUser() {
        
       let authenticator = OAuth1Swift( consumerKey: apiKey, consumerSecret: apiSecret,
                                        requestTokenUrl: requestTokenURL,
                                        authorizeUrl: authorizationURL,
                                        accessTokenUrl: accessTokenURL)
        
        authenticator.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: authenticator)
        
        _ =  authenticator.authorize(withCallbackURL: callBackURL!) { (result) in
            
            switch result {
            case .success(let (credential, _, _)):
                print("Here is your token: \(credential.oauthToken)")
                
            case .failure(let error):
                print("Authentication process ended with error: \(error)")
            }
            
        }
        
        
        
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
