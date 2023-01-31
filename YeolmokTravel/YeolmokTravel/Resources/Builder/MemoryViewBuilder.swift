//
//  MemoryViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

final class MemoryViewBuilder {
    private let memoryView: MemoryView
    private let memoryRepository: FirestoreMemoryRepository
    private let imageRepository: StorageMemoryRepository
    private let useCaseProvider: UseCaseProvider
    
    init(memoryView: MemoryView, memoryRepository: FirestoreMemoryRepository, imageRepository: StorageMemoryRepository, useCaseProvider: UseCaseProvider) {
        self.memoryView = memoryView
        self.memoryRepository = memoryRepository
        self.imageRepository = imageRepository
        self.useCaseProvider = useCaseProvider
    }
    
    private func downloadModel() async -> [Memory] {
        await memoryRepository.download().map { $0.toDomain() as! Memory }
    }
    
    private func setUpViewModel(_ model: [Memory]) {
        memoryView.viewModel = MemoryViewModel(useCaseProvider.createDefaultMemoryUseCase(model))
        memoryView.useCaseProvider = useCaseProvider
    }
    
    func build() async -> MemoryView {
        let model = await downloadModel()
        setUpViewModel(model)
        return memoryView
    }
}
