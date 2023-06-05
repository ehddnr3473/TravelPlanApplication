//
//  SceneDelegate.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appConfiguration: AppConfiguration?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        
        let plansSceneDIContainer = PlansSceneDIContainer()
        let memoriesSceneDIContainer = MemoriesSceneDIContainer()
        
        appConfiguration = AppConfiguration(plansContainer: plansSceneDIContainer,
                                            memoriesContainer: memoriesSceneDIContainer)
        appConfiguration?.configureMainInterface(in: window, tabBarController: tabBarController)
        
        window.makeKeyAndVisible()
        self.window = window
    }
}

