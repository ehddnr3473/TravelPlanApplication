//
//  MemoriesListViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Domain

protocol MemoriesListViewBuilder {
    func build() -> MemoriesListViewController
}

struct DefaultMemoriesListViewBuilder: MemoriesListViewBuilder {
    private let memoryUseCaseProvider: MemoriesUseCaseProvider
    private let memoryImageuseCaseProvider: ImagesUseCaseProvider
    
    init(_ memoryUseCaseProvider: MemoriesUseCaseProvider, _ memoryImageUseCaseProvider: ImagesUseCaseProvider) {
        self.memoryUseCaseProvider = memoryUseCaseProvider
        self.memoryImageuseCaseProvider = memoryImageUseCaseProvider
    }
    
    private func createViewModel() -> DefaultMemoriesListViewModel {
        DefaultMemoriesListViewModel(memoryUseCaseProvider)
    }
    
    func build() -> MemoriesListViewController {
        let viewModel = createViewModel()
        return MemoriesListViewController(viewModel, memoryUseCaseProvider, memoryImageuseCaseProvider)
    }
}
