//
//  MemoryDeleteUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryDeleteUseCase {
    func execute(at index: Int) async throws
}

struct ConcreteMemoryDeleteUseCase: MemoryDeleteUseCase {
    private let repository: AbstractMemoryRepository
    
    init(_ repository: AbstractMemoryRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int) async throws {
        try await repository.delete(at: index)
    }
}
