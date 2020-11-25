//
//  SceneDelegate.swift
//  Assignment
////  ID: 30733154
//  FIT5040 - Advanced Mobile Applications
//  Created by Flloyd Dsouza on 8/25/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreLocation
class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var alert: Bool = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
         locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.databaseController?.cleanup()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // Refered to Videos under Moodle for setting up GeoFence using SceneDelegate
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Geo Location Triggered")
        if UIApplication.shared.applicationState == .active && alert == false {
            alert =  true
            let regionName = region.identifier
            let alert = UIAlertController(title: regionName, message: "You have entered the Botanical Site \(regionName) ! ", preferredStyle: .alert)
            let dismis = UIAlertAction(title: "Dismiss", style: .default, handler: handleDismiss)
            alert.addAction(dismis)
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func handleDismiss(alertAction: UIAlertAction!) -> Void{
        alert = false
    }
    
}

