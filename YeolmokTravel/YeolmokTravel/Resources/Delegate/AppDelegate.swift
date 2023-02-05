//
//  AppDelegate.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            FirebaseApp.configure()
            return true
        }
        
        // 13 이전의 경우에는 SceneDelegate에서 해주었던 작업을 그대로 진행
        window = UIWindow()
        let planRepository = FirestorePlanRepository()
        let memoryRepository = FirestoreMemoryRepository()
        let imageRepository = StorageMemoryRepository()
        
        let useCaseProvider = UseCaseProvider(planRepository: planRepository,
                                              memoryRepository: memoryRepository,
                                              storageRepository: imageRepository)
        let planViewBuilder = PlanViewBuilder(planRepository: planRepository,
                                              useCaseProvider: useCaseProvider)
        
        let memoryViewBuilder = MemoryViewBuilder(memoryRepository: memoryRepository,
                                                  imageRepository: imageRepository,
                                                  useCaseProvider: useCaseProvider)
        
        let tabBarController = TabBarController()
        tabBarController.planViewBuilder = planViewBuilder
        tabBarController.memoryViewBuilder = memoryViewBuilder
        window?.makeKeyAndVisible()
        FirebaseApp.configure()
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


}

