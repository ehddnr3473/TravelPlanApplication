//
//  WritableSchedule.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

struct WritableSchedule {
    var schedule: Schedule
    var initialSchedule: Schedule
    
    init(_ schedule: Schedule) {
        self.schedule = schedule
        self.initialSchedule = schedule
    }
    
    var tile: String {
        schedule.title
    }
    
    var date: String {
        if let date = schedule.date {
            return date.formatted()
        } else {
            return ""
        }
    }
}
