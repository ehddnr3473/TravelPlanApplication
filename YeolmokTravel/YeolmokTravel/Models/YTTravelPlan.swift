//
//  Plan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import CoreLocation
import Domain

/// 여행 계획 모델
struct YTTravelPlan {
    var title: String
    var description: String
    var fromDate: Date?
    var toDate: Date?
    var schedules: [YTSchedule] {
        didSet {
            setFromDate()
            setToDate()
        }
    }
    
    var coordinates: [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        for schedule in schedules {
            coordinates.append(schedule.coordinate)
        }
        return coordinates
    }
    
    init(title: String,
         description: String,
         fromDate: Date? = nil,
         toDate: Date? = nil,
         schedules: [YTSchedule]) {
        self.title = title
        self.description = description
        self.fromDate = fromDate
        self.toDate = toDate
        self.schedules = schedules
        
        setFromDate()
        setToDate()
    }
    
    init(travelPlan: TravelPlan) {
        self.title = travelPlan.title
        self.description = travelPlan.description
        self.schedules = travelPlan.schedules.map { YTSchedule(schedule: $0) }
    }
    
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
    
    mutating func setFromDate() {
        fromDate = schedules.compactMap { $0.fromDate }.min()
    }
    
    mutating func setToDate() {
        toDate = schedules.compactMap { $0.toDate }.max()
    }
}

extension YTTravelPlan: Equatable {
    static func == (lhs: YTTravelPlan, rhs: YTTravelPlan) -> Bool {
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.fromDate == rhs.fromDate &&
        lhs.toDate == rhs.toDate &&
        lhs.schedules == rhs.schedules
    }
}

extension YTTravelPlan {
    func toDomain() -> TravelPlan {
        TravelPlan(title: title,
                   description: description,
                   fromDate: fromDate,
                   toDate: toDate,
                   schedules: schedules.map { $0.toDomain() })
    }
}
