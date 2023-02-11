//
//  MemoryDTO.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

/// Data Transfer Object
/// MemoryDTO(Data) -> Memory(Domain)
struct MemoryDTO {
    let title: String
    let index: Int
    let uploadDate: Date
}

// MARK: - Mapping to domain
extension MemoryDTO {
    func toDomain() -> Memory {
        Memory(title: title, index: index, uploadDate: uploadDate)
    }
}
