//
//  AppConfiguration.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/25.
//

import Foundation
import UIKit

final class AppConfiguration {
    private let plansSceneDIContainer: PlansSceneDIContainer
    private let memoriesSceneDIContainer: MemoriesSceneDIContainer
    
    private var plansFlowCoordinator: PlansFlowCoordinator?
    private var memoriesFlowCoordinator: MemoriesFlowCoordinator?
    
    init(plansContainer: PlansSceneDIContainer,
         memoriesContainer: MemoriesSceneDIContainer) {
        self.plansSceneDIContainer = plansContainer
        self.memoriesSceneDIContainer = memoriesContainer
    }
    
    func configureMainInterface(in window: UIWindow, tabBarController: UITabBarController) {
        let plansNavigationController = UINavigationController()
        plansNavigationController.tabBarItem = UITabBarItem(title: TitleConstants.plan,
                                                 image: UIImage(systemName: ImageNames.note),
                                                 tag: NumberConstants.first)
        let plansFlowCoordinator = DefaultPlansFlowCoordinator(navigationController: plansNavigationController,
                                                       container: plansSceneDIContainer)
        
        let memoriesNavigationController = UINavigationController()
        memoriesNavigationController.tabBarItem = UITabBarItem(title: TitleConstants.memory,
                                             image: UIImage(systemName: ImageNames.memory),
                                             tag: NumberConstants.second)
        let memoriesFlowCoordinator = DefaultMemoriesFlowCoordinator(navigationController: memoriesNavigationController,
                                                             container: memoriesSceneDIContainer)
        
        tabBarController.viewControllers = [
            plansNavigationController,
            memoriesNavigationController
        ]
        
        tabBarController.tabBar.barTintColor = .systemBackground
        tabBarController.tabBar.tintColor = AppStyles.mainColor
        tabBarController.tabBar.unselectedItemTintColor = .systemGray
        tabBarController.viewControllers = [plansNavigationController, memoriesNavigationController]
        tabBarController.setViewControllers(tabBarController.viewControllers, animated: true)
        
        window.rootViewController = tabBarController
        
        plansFlowCoordinator.start()
        memoriesFlowCoordinator.start()
        
        self.plansFlowCoordinator = plansFlowCoordinator
        self.memoriesFlowCoordinator = memoriesFlowCoordinator
    }
}

private extension AppConfiguration {
    @frozen enum NumberConstants {
        static let first = 0
        static let second = 1
    }
    
    @frozen enum TitleConstants {
        static let plan = "Plans"
        static let memory = "Memories"
    }

    @frozen enum ImageNames {
        static let note = "note.text"
        static let memory = "photo.artframe"
    }
}
