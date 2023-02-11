//
//  MemoryUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryUploadUseCase: AnyObject {
    func execute(at index: Int, _ memory: Memory) async throws
}

final class ConcreteMemoryUploadUseCase: MemoryUploadUseCase {
    private let repository: AbstractMemoryRepository
    
    init(_ repository: AbstractMemoryRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int, _ memory: Memory) async throws {
        try await repository.upload(at: index, memoryDTO: memory.toData())
    }
}
