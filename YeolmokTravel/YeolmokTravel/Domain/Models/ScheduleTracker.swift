//
//  ScheduleTracker.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/10.
//

import Foundation

import Foundation

/// Schedule의 변경 사항을 추적하고 alert을 띄워주기 위한 데이터 struct
struct ScheduleTracker {
    var schedule: Schedule
    private let initialSchedule: Schedule
    
    // 변경된 내용을 확인하기 위해 초기값 저장
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
