//
//  MemoryImageDeleteUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation

protocol MemoryImageDeleteUseCase: AnyObject {
    func execute(at index: Int) async throws
}

final class ConcreteMemoryImageDeleteUseCase: MemoryImageDeleteUseCase {
    private let repository: AbstractMemoryImageRepository
    
    init(_ repository: AbstractMemoryImageRepository) {
        self.repository = repository
    }
    
    func execute(at index: Int) async throws {
        try await repository.delete(index)
    }
}
