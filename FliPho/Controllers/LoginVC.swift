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
//    let fileManager = FileManager()
    
    
    
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
        
        _ =  authObject.authorize(withCallbackURL: callBackURL!) { [weak self] (result) in
            
            switch result {
            case .success(let (_, _, parameters)):
                
                if let user_nsid = parameters["user_nsid"] as? String {
                    
                    guard let userID = user_nsid.removingPercentEncoding else { return }
                    self?.userDefaults.set(userID, forKey: "user_nsid")
                    self?.authenticateUser(userID, with: authObject)
                }

            case .failure( _):
                self?.showAlert(with: "Make sure you're connected to internet")
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
                }
            case .failure( _):
                DispatchQueue.main.async {
                    self.showAlert(with: "Authentication: something went wrong")
                }
            }
        }
    }
    
     // MARK: - Alert
    
    enum Failure: Error {
        case failedWritingToFile
        case missingFile
        case failedReadingFile
        case failedDecodingFile
        
        var errorDescription: String {
            
            switch self {
            case .failedReadingFile:
                return "Failed reading from file"
                
            case .failedWritingToFile:
                return "Failed writing to file"
                
            case .missingFile:
                return "File is missing"
                
            case .failedDecodingFile:
                return "Failed decoding file"
            }
        }
    }
    
    func showAlert(with errorMessage: String) {
        
        let alert = UIAlertController(title: "Couldn't sign you in", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func authenticateUser(_ userID: String, with authenticationObject: OAuth1Swift) {
        
        guard let userInfoURL = FlickrURLs.fetchUserInfo(userID: userID) else { return }
        
        let networkManager = NetworkManager()
        
        networkManager.fetchData(from: userInfoURL) { [weak self ] result in

            switch result {
            case .failure(let error):
                print("Authentication error: \(error.localizedDescription)")

            case .success(let data):
                guard let userData = self?.decodeUserInfo(from: data) else { return }
                self?.saveUserInfo(userData)
                
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "mainMenu", sender: nil)
                }
            }
        }
    }
    
    func decodeUserInfo(from data: Data) -> Result<User, Failure> {
        
        let decoder = JSONDecoder()
        let decodedData = try? decoder.decode(DecodedUserInfo.self, from: data)
        guard let userData = decodedData?.person else { print("Errors while decoding UserData: \(Failure.failedDecodingFile.errorDescription)"); return .failure(.failedDecodingFile)}
        let user = User(userID: userData.id, userName: userData.username.content, iconServer: userData.iconserver, iconFarm: userData.iconfarm)
        _ = user.iconURL
        
        return .success(user)
    }
    
    func saveUserInfo(_ userData: Result<User, Failure>) {
        
        let plistEncoder = PropertyListEncoder()
        plistEncoder.outputFormat = .xml
        
        let userDirectoryPath = FileManager.documentsDirectory
        let fileToSaveInto = URL(fileURLWithPath: "SavedUserData", relativeTo: userDirectoryPath).appendingPathExtension("plist")
        print("File location: \(fileToSaveInto.path)")
        
        switch userData {
            
        case .failure(let error ):
            print("Error: \(error.localizedDescription)")
            
        case .success(let user):
            do {
                let dataToBeSaved = try plistEncoder.encode(user)
                try dataToBeSaved.write(to: fileToSaveInto, options: .atomic)

            } catch {
                print("Errors while writing user to Documents Directory: \(error.localizedDescription)")
            }
        }
    }
    
    func retrieveUserInfo() throws -> User {
        
        let plistDecoder = PropertyListDecoder()
        let filePath = FileManager.documentsDirectory
        let file = filePath.appendingPathComponent("SavedUserData").appendingPathExtension("plist")
        guard let retrievedData = try? Data(contentsOf: file) else { print("Errors: \(Failure.missingFile.errorDescription)"); throw Failure.missingFile }
        guard let decodedUserData = try? plistDecoder.decode(User.self, from: retrievedData) else { print("Error: \(Failure.failedDecodingFile.errorDescription)"); throw Failure.failedDecodingFile}

        return decodedUserData
    }
    
}
