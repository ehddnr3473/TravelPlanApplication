//
//  MemoryUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryUploadUseCase {
    func execute(at index: Int, _ memory: Memory) async throws
}

struct ConcreteMemoryUploadUseCase: MemoryUploadUseCase {
    private let memoryRepository: AbstractMemoryRepository
    
    init(_ memoryRepository: AbstractMemoryRepository) {
        self.memoryRepository = memoryRepository
    }
    
    func execute(at index: Int, _ memory: Memory) async throws {
        try await memoryRepository.upload(at: index, memoryDTO: memory.toData())
    }
}
