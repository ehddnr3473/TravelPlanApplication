//
//  MemoryPostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/23.
//

import Foundation

struct MemoryPostsUseCase: FirestorePostsUseCase {
    var repository: MemoryRepository
    
    init(repository: MemoryRepository) {
        self.repository = repository
    }
    
    func upload(at index: Int, entity: Memory) {
        Task { await repository.upload(at: index, entity: entity.toData()) }
    }
    
    func delete(at index: Int) {
        Task { await repository.delete(at: index) }
    }
}
