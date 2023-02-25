//
//  YTMemory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/25.
//

import Foundation
import Domain

struct YTMemory {
    let title: String
    let index: Int
    let uploadDate: Date
    
    init(title: String, index: Int, uploadDate: Date) {
        self.title = title
        self.index = index
        self.uploadDate = uploadDate
    }
    
    init(memory: Memory) {
        self.title = memory.title
        self.index = memory.index
        self.uploadDate = memory.uploadDate
    }
}

extension YTMemory: Hashable {
    var id: Int {
        index
    }
}

extension YTMemory {
    func toDomain() -> Memory {
        Memory(title: title,
               index: index,
               uploadDate: uploadDate)
    }
}
