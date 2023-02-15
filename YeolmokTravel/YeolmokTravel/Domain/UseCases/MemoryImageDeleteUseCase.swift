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
    private let memoryImageRepository: AbstractMemoryImageRepository
    
    init(_ memoryImageRepository: AbstractMemoryImageRepository) {
        self.memoryImageRepository = memoryImageRepository
    }
    
    func execute(at index: Int) async throws {
        try await memoryImageRepository.delete(index)
    }
}
