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
        container.register(PlansRepository.self) { _ in DefaultPlansRepository() }
        container.register(MemoriesRepository.self) { _ in DefaultMemoriesRepository() }
        container.register(ImagesRepository.self) { _ in DefaultImagesRepository() }
        
        // UseCaseProvider
        container.register(PlansUseCaseProvider.self) { resolver in
            DefaultPlansUseCaseProvider(repository: resolver.resolve(PlansRepository.self)!)
        }
        
        container.register(MemoriesUseCaseProvider.self) { resolver in
            DefaultMemoriesUseCaseProvider(repository: resolver.resolve(MemoriesRepository.self)!)
        }
        
        container.register(ImagesUseCaseProvider.self) { resolver in
            DefaultImagesUseCaseProvider(repository: resolver.resolve(ImagesRepository.self)!)
        }
        
        // ViewBuilder
        container.register(PlansListViewBuilder.self) { resolver in
            DefaultPlansListViewBuilder(resolver.resolve(PlansUseCaseProvider.self)!)
        }
        
        container.register(MemoriesListViewBuilder.self) { resolver in
            DefaultMemoriesListViewBuilder(resolver.resolve(MemoriesUseCaseProvider.self)!, resolver.resolve(ImagesUseCaseProvider.self)!)
        }
        
        let tabBarController = TabBarController(container.resolve(PlansListViewBuilder.self)!, container.resolve(MemoriesListViewBuilder.self)!)
        
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

