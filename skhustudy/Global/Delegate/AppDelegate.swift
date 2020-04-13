//
//  AppDelegate.swift
//  skhustudy
//
//  Created by Junhyeon on 2020/04/09.
//  Copyright © 2020 skhuStudy. All rights reserved.
//

import UIKit
<<<<<<< Updated upstream
import KakaoOpenSDK
import FBSDKCoreKit
=======
import Firebase
>>>>>>> Stashed changes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
<<<<<<< Updated upstream
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
            launchOptions
        )
        
=======
        FirebaseApp.configure()
>>>>>>> Stashed changes
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       if KOSession.handleOpen(url) {
          return true
       }
          return false
    }
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       if KOSession.handleOpen(url) {
          return true
       }
//          return false
        
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            options: options
        )
    }

    
}
