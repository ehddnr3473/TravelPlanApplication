//
//  ScheduleTracker.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/10.
//

import Foundation

import struct Domain.Schedule

/// Schedule의 변경 사항을 추적하고 alert을 띄워주기 위한 데이터 struct
struct ScheduleTracker {
    var schedule: Schedule
    private let initialSchedule: Schedule
    
    init(_ schedule: Schedule) {
        self.schedule = schedule
        self.initialSchedule = schedule
    }
    
    var isChanged: Bool {
        if schedule == initialSchedule {
            return false
        } else {
            return true
        }
    }
}
