//
//  MemoryDTO.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

struct MemoryDTO {
    let title: String
    let index: Int
    let uploadDate: Date
}

extension MemoryDTO {
    func toDomain() -> Memory {
        .init(
            title: title,
            index: index,
            uploadDate: uploadDate
        )
    }
}
