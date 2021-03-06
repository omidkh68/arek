//
//  ArekNotifications.swift
//  arek
//
//  Created by Ennio Masi on 08/11/2016.
//  Copyright © 2016 ennioma. All rights reserved.
//

import Foundation

import UIKit
import UserNotifications

class ArekNotifications: ArekBasePermission, ArekPermissionProtocol {
    var identifier: String = "ArekNotifications"
    //var notificationOptions: UNAuthorizationOptions = [.alert, .badge]
    
    override init() {
        super.init()
        super.permission = self
        
        self.initialPopupData = ArekPopupData(title: "Push notifications service", message: "enable")
        self.reEnablePopupData = ArekPopupData(title: "Push notifications service", message: "re enable 🙏")
    }
    
    required init(configuration: ArekConfiguration, initialPopupData: ArekPopupData?, reEnablePopupData: ArekPopupData?) {
        fatalError("init(configuration:initialPopupData:reEnablePopupData:) has not been implemented")
    }
    
    func status(completion: @escaping ArekPermissionResponse) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                case .notDetermined:
                    return completion(.NotDetermined)
                case .denied:
                    return completion(.Denied)
                case .authorized:
                    return completion(.Authorized)
                }
            }
        } else if #available(iOS 9.0, *) {
            if let types = UIApplication.shared.currentUserNotificationSettings?.types {
                if types.isEmpty {
                    return completion(.NotDetermined)
                }
            }
            
            return completion(.Authorized)
        }
    }
    
    func manage(completion: @escaping ArekPermissionResponse) {
        self.status { (status) in
            self.managePermission(status: status, completion: completion)
        }
    }
    
    func askForPermission(completion: @escaping ArekPermissionResponse) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
                if granted {
                    NSLog("Notifications permission authorized by user ✅")
                    return completion(.Authorized)
                }
                
                if let _ = error {
                    return completion(.NotDetermined)
                }
                
                NSLog("Notifications permission authorized by user ⛔️")
                return completion(.Denied)
            }
        } else if #available(iOS 9.0, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
