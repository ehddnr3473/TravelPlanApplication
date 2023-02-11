//
//  MemoryReadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryReadUseCase: AnyObject {
    func execute() async throws -> [Memory]
}

final class ConcreteMemoryReadUseCase: MemoryReadUseCase {
    private let repository: AbstractMemoryRepository
    
    init(_ repository: AbstractMemoryRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Memory] {
        try await repository.read().map { $0.toDomain() }
    }
}
