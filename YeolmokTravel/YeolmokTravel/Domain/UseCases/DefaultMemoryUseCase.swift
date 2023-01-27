//
//  MemoryDownloadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

final class DefaultMemoryUseCase {
    private var memories: [Memory]
    private let repository: FirestoreRepository
    
    var count: Int {
        memories.count
    }
    
    init(memories: [Memory], repository: FirestoreRepository) {
        self.memories = memories
        self.repository = repository
    }
    
    func memory(_ index: Int) -> Memory {
        memories[index]
    }
    
    func add(_ memory: Memory) {
        memories.append(memory)
    }
}
