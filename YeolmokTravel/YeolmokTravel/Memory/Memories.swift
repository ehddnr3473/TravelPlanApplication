//
//  Memories.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation

/// Memories Model
struct Memories {
    var memories: [Memory]
    
    var memoriesCount: Int {
        memories.count
    }
    
    func memory(at index: Int) -> Memory {
        memories[index]
    }
    
    mutating func addMemory(_ memory: Memory) {
        memories.append(memory)
    }
}
