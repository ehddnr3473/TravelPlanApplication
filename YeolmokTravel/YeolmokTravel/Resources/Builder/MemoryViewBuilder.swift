//
//  MemoryViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

protocol MemoryViewBuilder {
    func build() -> MemoryViewController
}

struct ConcreteMemoryViewBuilder: MemoryViewBuilder {
    private let memoryUseCaseProvider: MemoryUseCaseProvider
    private let memoryImageuseCaseProvider: MemoryImageUseCaseProvider
    
    init(_ memoryUseCaseProvider: MemoryUseCaseProvider, _ memoryImageUseCaseProvider: MemoryImageUseCaseProvider) {
        self.memoryUseCaseProvider = memoryUseCaseProvider
        self.memoryImageuseCaseProvider = memoryImageUseCaseProvider
    }
    
    private func createViewModel() -> ConcreteMemoryViewModel {
        ConcreteMemoryViewModel(memoryUseCaseProvider)
    }
    
    func build() -> MemoryViewController {
        let viewModel = createViewModel()
        return MemoryViewController(viewModel, memoryUseCaseProvider, memoryImageuseCaseProvider)
    }
}
