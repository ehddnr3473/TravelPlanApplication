//
//  MemoriesWriteFlowCoordinator.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/25.
//

import Foundation
import UIKit
import Domain

protocol MemoriesWriteFlowCoordinator: AnyObject {
    func start()
    func toWriteMemory(index: Int,
                       delegate: MemoryTransferDelegate,
                       _ memoriesUseCaseProvider: MemoriesUseCaseProvider,
                       _ imagesUseCaseProvider: ImagesUseCaseProvider)
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
    
    func toWriteMemory(index: Int,
                       delegate: MemoryTransferDelegate,
                       _ memoriesUseCaseProvider: MemoriesUseCaseProvider,
                       _ imagesUseCaseProvider: ImagesUseCaseProvider) {
        let writingMemoryViewController = container.makeWritingMemoryViewController(index: index,
                                                                                    delegate: delegate,
                                                                                    memoriesUseCaseProvider,
                                                                                    imagesUseCaseProvider)
        if let presentingViewController = delegate as? UIViewController {
            writingMemoryViewController.modalPresentationStyle = .fullScreen
            presentingViewController.present(writingMemoryViewController, animated: true)
        }
    }
}
