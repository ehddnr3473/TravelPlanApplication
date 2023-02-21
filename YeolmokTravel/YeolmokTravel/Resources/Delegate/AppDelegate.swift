//
//  AppDelegate.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit
import FirebasePlatform
import Domain
import Swinject


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            FirebaseManager.configure()
            return true
        }
        
        // 13 이전의 경우에는 SceneDelegate에서 해주었던 작업을 그대로 진행
        window = UIWindow()
        
        let container = Container()
        // Repository
        container.register(AbstractTravelPlanRepository.self) { _ in TravelPlanRepository() }
        container.register(AbstractMemoryRepository.self) { _ in MemoryRepository() }
        container.register(AbstractImageRepository.self) { _ in MemoryImageRepository() }
        // UseCaseProvider
        container.register(TravelPlanUseCaseProvider.self) { resolver in
            ConcreteTravelPlanUseCaseProvider(resolver.resolve(AbstractTravelPlanRepository.self)!)
        }
        
        container.register(MemoryUseCaseProvider.self) { resolver in
            ConcreteMemoryUseCaseProvider(resolver.resolve(AbstractMemoryRepository.self)!)
        }
        
        container.register(MemoryImageUseCaseProvider.self) { resolver in
            ConcreteMemoryImageUseCaseProvider(resolver.resolve(AbstractImageRepository.self)!)
        }
        // ViewBuilder
        container.register(TravelPlanViewBuilder.self) { resolver in
            ConcreteTravelPlanViewBuilder(resolver.resolve(TravelPlanUseCaseProvider.self)!)
        }
        
        container.register(MemoryViewBuilder.self) { resolver in
            ConcreteMemoryViewBuilder(resolver.resolve(MemoryUseCaseProvider.self)!, resolver.resolve(MemoryImageUseCaseProvider.self)!)
        }
        
        let tabBarController = TabBarController(container.resolve(TravelPlanViewBuilder.self)!, container.resolve(MemoryViewBuilder.self)!)
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        FirebaseManager.configure()
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

