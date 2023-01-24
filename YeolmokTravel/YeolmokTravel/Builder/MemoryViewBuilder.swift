//
//  MemoryViewBuilder.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

struct MemoryViewBuilder {
    private var memoryView: MemoryView
    private var memoryRepository: MemoryRepository
    
    init(memoryView: MemoryView, memoryRepository: MemoryRepository) {
        self.memoryView = memoryView
        self.memoryRepository = memoryRepository
    }
    
    private func downloadModel() async -> [Memory] {
        await memoryRepository.downloadMemories().map { $0.toDomain() }
    }
    
    private func setUpUseCase(_ model: [Memory]) -> DefaultMemoryUseCase {
        DefaultMemoryUseCase(memories: model)
    }
    
    private func setUpViewModel(_ useCase: DefaultMemoryUseCase) {
        memoryView.viewModel = MemoryViewModel(useCase: useCase)
    }
    
    func build() async -> MemoryView {
        let model = await downloadModel()
        let useCase = setUpUseCase(model)
        setUpViewModel(useCase)
        return memoryView
    }
}
