//
//  Schedule.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// 자세한 일정을 나타내는 모델
/// TravelPlan의 하위 데이터
struct Schedule: Plan {
    var title: String
    var description: String
    var fromDate: Date?
    var toDate: Date?
    
    var date: String {
        if let fromDate = fromDate, let toDate = toDate {
            if fromDate == toDate {
                return DateConverter.dateToString(fromDate)
            } else {
                return "\(DateConverter.dateToString(fromDate)) ~ \(DateConverter.dateToString(toDate))"
            }
        } else {
            return DateConverter.nilDateText
        }
    }
    
    mutating func setSchedule(_ title: String, _ description: String, _ fromDate: Date? = nil, _ toDate: Date? = nil) {
        self.title = title
        self.description = description
        self.fromDate = fromDate
        self.toDate = toDate
    }
}

extension Schedule: Model {
    func toData() -> Entity {
        ScheduleDTO(title: title, description: description, fromDate: fromDate, toDate: toDate)
    }
}
