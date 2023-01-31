//
//  ScheduleDTO.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

/// Data Transfer Object
/// ScheduleDTO(Data) -> Schedule(Domain)
struct ScheduleDTO {
    let title: String
    let description: String
    let fromDate: Date?
    let toDate: Date?
}

// MARK: - Mapping to domain
extension ScheduleDTO: Entity {
    func toDomain() -> Model {
        Schedule(title: title, description: description, fromDate: fromDate, toDate: toDate)
    }
}
