//
//  MemoryDownloadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

final class DefaultMemoryUseCase {
    private var memories: [Memory]
    
    var count: Int {
        memories.count
    }
    
    init(memories: [Memory]) {
        self.memories = memories
    }
    
    func memory(_ index: Int) -> Memory {
        memories[index]
    }
    
    func add(_ memory: Memory) {
        memories.append(memory)
    }
}
