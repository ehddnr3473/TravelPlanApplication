//
//  MemoriesWriteFlowCoordinator.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/25.
//

import Foundation
import UIKit

protocol MemoriesWriteFlowCoordinator: AnyObject {
    func start()
    func toWriteMemory(_ box: MemoriesSceneDIContainer.WritingMemoryBox)
}

final class DefaultMemoriesWriteFlowCoordinator: MemoriesWriteFlowCoordinator {
    private let navigationController: UINavigationController?
    private let container: MemoriesSceneDIContainer
    
    init(navigationController: UINavigationController, container: MemoriesSceneDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        navigationController?.pushViewController(container.makeMemoriesListViewController(coordinator: self), animated: true)
    }
    
    func toWriteMemory(_ box: MemoriesSceneDIContainer.WritingMemoryBox) {
        let writingMemoryViewController = container.makeWritingMemoryViewController(box)
        
        if let presentingViewController = box.delegate as? UIViewController {
            writingMemoryViewController.modalPresentationStyle = .fullScreen
            presentingViewController.present(writingMemoryViewController, animated: true)
        }
    }
}
