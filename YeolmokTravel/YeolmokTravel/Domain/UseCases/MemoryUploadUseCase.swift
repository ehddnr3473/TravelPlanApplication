//
//  MemoryUploadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryUploadUseCase: AnyObject {
    func execute(at index: Int, model: Memory) async throws
}

final class ConcreteMemoryUploadUseCase: MemoryUploadUseCase {
    private let repository: AbstractMemoryRepository
    
    init(_ repository: AbstractMemoryRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int, model: Memory) async throws {
        try await repository.upload(at: index, entity: model.toData())
    }
    
    func delete(at index: Int) async throws {
        try await repository.delete(at: index)
    }
}
