//
//  Plan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// 여행 계획 엔티티
struct TravelPlan: Plan {
    var title: String
    var description: String?
    var date: Date?
    let schedules: [Schedule]
}
