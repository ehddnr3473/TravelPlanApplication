//
//  MemoriesSceneDIContainer.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/24.
//

import Foundation
import Domain
import FirebasePlatform

final class MemoriesSceneDIContainer {
    // MARK: - Use Case Providers
    private func makeMemoriesUseCaseProvider() -> MemoriesUseCaseProvider {
        DefaultMemoriesUseCaseProvider(repository: makeMemoriesRepository())
    }
    
    private func makeImagesUseCaseProvider() -> ImagesUseCaseProvider {
        DefaultImagesUseCaseProvider(repository: makeImagesRepository())
    }
    
    // MARK: - Repositories
    private func makeMemoriesRepository() -> MemoriesRepository {
        DefaultMemoriesRepository()
    }
    
    private func makeImagesRepository() -> ImagesRepository {
        DefaultImagesRepository()
    }
    
    // MARK: - Memories List
    func makeMemoriesListViewController(coordinator: MemoriesWriteFlowCoordinator) -> MemoriesListViewController {
        MemoriesListViewController(
            viewModel: makeMemoriesListViewModel(),
            coordinator: coordinator,
            memoriesUseCaseProvider: makeMemoriesUseCaseProvider(),
            imagesUseCaseProvider: makeImagesUseCaseProvider()
        )
    }
    
    private func makeMemoriesListViewModel() -> MemoriesListViewModel {
        DefaultMemoriesListViewModel(useCaseProvider: makeMemoriesUseCaseProvider())
    }
    
    // MARK: - Writing Memory
    func makeWritingMemoryViewController(_ box: WritingMemoryBox) -> WritingMemoryViewController {
        WritingMemoryViewController(
            viewModel: makeWritingMemoryViewModel(
                box.memoriesUseCaseProvider,
                box.imagesUseCaseProvider
            ),
            memoriesListIndex: box.memoriesListIndex,
            delegate: box.delegate
        )
    }
    
    private func makeWritingMemoryViewModel(_ memoriesUseCaseProvider: MemoriesUseCaseProvider,
                                            _ imagesUseCaseProvider: ImagesUseCaseProvider) -> DefaultWritingMemoryViewModel {
        DefaultWritingMemoryViewModel(
            memoriesUseCaseProvider: memoriesUseCaseProvider,
            imagesUseCaseProvider: imagesUseCaseProvider
        )
    }
}

extension MemoriesSceneDIContainer {
    struct WritingMemoryBox {
        let memoriesUseCaseProvider: MemoriesUseCaseProvider
        let imagesUseCaseProvider: ImagesUseCaseProvider
        let delegate: MemoryTransferDelegate
        let memoriesListIndex: Int
    }
}
