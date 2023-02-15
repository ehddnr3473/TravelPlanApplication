//
//  MemoryReadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryReadUseCase {
    func execute() async throws -> [Memory]
}

struct ConcreteMemoryReadUseCase: MemoryReadUseCase {
    private let repository: AbstractMemoryRepository
    
    init(_ repository: AbstractMemoryRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Memory] {
        try await repository.read()
    }
}
