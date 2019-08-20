//
//  AppDelegate.swift
//  On The Map
//
//  Created by Glenn Cole on 8/14/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let appName = "On The Map"

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if ParseClient.Auth.isLoggedIn {
            ParseClient.Auth.isLoggedIn = false
            ParseClient.killSession(completion: logKilledSession(success:error:))
        }
    }
    private func logKilledSession( success: Bool, error: Error? ) {
        
        if success {
            print( "Session killed successfully" )
        }
        else {
            print( "Session kill failed: \(error!)" )
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        let vc = LoginViewController.instantiate() as! LoginViewController
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }

}

