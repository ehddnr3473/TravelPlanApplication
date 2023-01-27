//
//  MemoryDTO.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

struct MemoryDTO: Entity {
    let title: String
    let index: Int
    let uploadDate: Date
}

// MARK: - Mapping to domain
extension MemoryDTO {
    func toDomain() -> Model {
        Memory(title: title, index: index, uploadDate: uploadDate)
    }
}
