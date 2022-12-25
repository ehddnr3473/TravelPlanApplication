//
//  Memories.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation

/// Memories Model
struct Memories {
    private(set) var memories: [Memory]
    private let repository = MemoryRepository()
    
    mutating func add(_ memory: Memory) {
        memories.append(memory)
    }
    
    func write(at index: Int) async {
        await repository.writeMemory(memories[index])
    }
}
