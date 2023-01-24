//
//  MemoryUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/23.
//

import Foundation

protocol MemoryUploadUseCaseType {
    func upload(_ memory: Memory)
    func delete(_ index: Int)
}

struct MemoryUploadUseCase: MemoryUploadUseCaseType {
    private let repository = MemoryRepository()
    
    func upload(_ memory: Memory) {
        Task { await repository.writeMemory(memory) }
    }
    
    func delete(_ index: Int) {
        Task { await repository.delete(at: index) }
    }
}
