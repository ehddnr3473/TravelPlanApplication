//
//  Schedule.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import CoreLocation

/// 자세한 일정을 나타내는 모델
/// TravelPlan의 하위 데이터
struct Schedule {
    var title: String
    var description: String
    var coordinate: CLLocationCoordinate2D
    var fromDate: Date?
    var toDate: Date?
    
    var date: String {
        if let fromDate = fromDate, let toDate = toDate {
            let slicedFromDate = DateConverter.dateToString(fromDate)
            let slicedToDate = DateConverter.dateToString(toDate)
            if slicedFromDate == slicedToDate {
                return slicedFromDate
            } else {
                return "\(slicedFromDate) ~ \(slicedToDate)"
            }
        } else {
            return DateConverter.nilDateText
        }
    }
}

extension Schedule {
    func toData() -> ScheduleDTO {
        ScheduleDTO(
            title: title,
            description: description,
            coordinate: coordinate,
            fromDate: fromDate,
            toDate: toDate
        )
    }
}

extension Schedule: Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.fromDate == rhs.fromDate &&
        lhs.toDate == rhs.toDate &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
