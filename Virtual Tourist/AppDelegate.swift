//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/24/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Declare the core data stack
    let dataController = DataController(modelName: "VirtualTourist")
    
    // Loades the persistent store and inject the data controller to the travel locations map view controller
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.loadPersistentStore()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsMapViewController = navigationController.topViewController as! TravelLocationsMapViewController
        travelLocationsMapViewController.dataController = dataController
        return true
    }
    
    // Save the view context when the app is in the background
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    
    // Save the view context when the app terminates or crashes
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    // MARK: Helper methods
    // A helper method that saves changes to the persistent store
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
    // MARK: Shared methods
    // A helper method that shows an Alert Box containing a given message
    // shared across different controllers
    func showError(controller: UIViewController, title: String,message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alertVC, animated: true, completion: nil)
    }
    
}

