//
//  MemoryViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

final class MemoryViewBuilder {
    private let memoryRepository: FirestoreMemoryRepository
    private let imageRepository: StorageMemoryRepository
    private let useCaseProvider: UseCaseProvider
    
    init(memoryRepository: FirestoreMemoryRepository, imageRepository: StorageMemoryRepository, useCaseProvider: UseCaseProvider) {
        self.memoryRepository = memoryRepository
        self.imageRepository = imageRepository
        self.useCaseProvider = useCaseProvider
    }
    
    private func downloadModel() async -> [Memory] {
        await memoryRepository.download().map { $0.toDomain() as! Memory }
    }
    
    private func configureViewModel(_ model: [Memory]) -> MemoryViewModel {
        MemoryViewModel(useCaseProvider.createDefaultMemoryUseCase(model))
    }
    
    func build() async -> MemoryView {
        let model = await downloadModel()
        let viewModel = configureViewModel(model)
        return await MemoryView(viewModel, useCaseProvider: useCaseProvider)
    }
}
