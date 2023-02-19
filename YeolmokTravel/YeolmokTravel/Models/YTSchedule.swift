//
//  YTSchedule.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import CoreLocation
import Domain

/// 자세한 일정을 나타내는 모델
/// TravelPlan의 하위 데이터
struct YTSchedule {
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
    
    init(title: String,
         description: String,
         coordinate: CLLocationCoordinate2D,
         fromDate: Date? = nil,
         toDate: Date? = nil) {
        self.title = title
        self.description = description
        self.coordinate = coordinate
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
    init(schedule: Schedule) {
        self.title = schedule.title
        self.description = schedule.description
        self.coordinate = schedule.coordinate
        self.fromDate = schedule.fromDate
        self.toDate = schedule.toDate
    }
}

extension YTSchedule: Equatable {
    static func == (lhs: YTSchedule, rhs: YTSchedule) -> Bool {
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.fromDate == rhs.fromDate &&
        lhs.toDate == rhs.toDate &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

extension YTSchedule {
    func toDomain() -> Schedule {
        Schedule(title: title,
                 description: description,
                 coordinate: coordinate,
                 fromDate: fromDate,
                 toDate: toDate)
    }
}
