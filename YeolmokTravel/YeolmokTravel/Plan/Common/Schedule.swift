//
//  Schedule.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// 자세한 일정을 나타내는 엔티티
/// TravelPlan의 하위 데이터
struct Schedule: Plan {
    var title: String
    var description: String?
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
}
