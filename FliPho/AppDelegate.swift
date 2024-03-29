//
//  AppDelegate.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        OAuthSwift.handle(url: url)
        return true

    }


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        let userData = try? retrieveUserInfo()
        if let usernsid = userData?.userNSID {
            print("App did finishLaunching with user_nsid: \(usernsid)")
            performSegueToMainMenu()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    fileprivate func retrieveUserInfo() throws -> User? {
        
        let plistDecoder = PropertyListDecoder()
        let filePath = FileManager.documentsDirectory
        let file = filePath.appendingPathComponent("SavedUserData").appendingPathExtension("plist")
        guard let retrievedData = try? Data(contentsOf: file) else { return nil }
        guard let decodedUserData = try? plistDecoder.decode(User.self, from: retrievedData) else { return nil }

        return decodedUserData
    }
    
    fileprivate func performSegueToMainMenu() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if let tabBarViewController = storyBoard.instantiateViewController(withIdentifier: "tabView") as? UITabBarController {
            self.window?.rootViewController = tabBarViewController
        }
    }


}

