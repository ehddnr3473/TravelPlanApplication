//
//  MemoryPostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/23.
//

import Foundation

/// Firestore 관련 use case
struct MemoryPostsUseCase: FirestorePostsUseCase {
    private let repository: FirestoreRepository
    
    init(repository: FirestoreRepository) {
        self.repository = repository
    }
    
    func upload(at index: Int, entity: Model) {
        Task { await repository.upload(at: index, entity: entity.toData()) }
    }
    
    func delete(at index: Int) {
        Task { await repository.delete(at: index) }
    }
}
