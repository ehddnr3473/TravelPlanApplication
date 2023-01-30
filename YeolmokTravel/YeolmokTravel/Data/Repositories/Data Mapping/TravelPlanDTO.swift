//
//  TravelPlanDTO.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation

struct TravelPlanDTO {
    let title: String
    let description: String
    let schedules: [ScheduleDTO]
}

// MARK: - Mapping to domain
extension TravelPlanDTO: Entity {
    func toDomain() -> Model {
        let schedules = schedules.map { $0.toDomain() as! Schedule }
        return TravelPlan(title: title, description: description, schedules: schedules)
    }
}
