//
//  Memory.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation

/// Memory Model
struct Memory: Hashable {
    let title: String
    let index: Int
    let uploadDate: Date
    
    var id: Int {
        index
    }
}

extension Memory {
    func toData() -> MemoryDTO {
        MemoryDTO(title: title, index: index, uploadDate: uploadDate)
    }
}
