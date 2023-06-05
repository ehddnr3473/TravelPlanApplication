//
//  AppDelegate.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

import struct FirebasePlatform.FirebaseManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appConfiguration: AppConfiguration?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            FirebaseManager.configure()
            return true
        }
        
        FirebaseManager.configure()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarController = UITabBarController()
        
        let plansSceneDIContainer = PlansSceneDIContainer()
        let memoriesSceneDIContainer = MemoriesSceneDIContainer()
        
        appConfiguration = AppConfiguration(plansContainer: plansSceneDIContainer,
                                            memoriesContainer: memoriesSceneDIContainer)
        appConfiguration?.configureMainInterface(in: window, tabBarController: tabBarController)
        
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

