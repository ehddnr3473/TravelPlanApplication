//
//  ScheduleDTO.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

struct ScheduleDTO: Entity {
    let title: String
    let description: String
    let fromDate: Date?
    let toDate: Date?
}

// MARK: - Mapping to domain
extension ScheduleDTO {
    func toDomain() -> Schedule {
        .init(
            title: title,
            description: description,
            fromDate: fromDate,
            toDate: toDate
        )
    }
}
