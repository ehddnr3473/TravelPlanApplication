//
//  Plan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import CoreLocation

/// 여행 계획 모델
struct TravelPlan {
    var title: String
    var description: String
    var fromDate: Date?
    var toDate: Date?
    var schedules: [Schedule] {
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
    
    init(title: String, description: String, fromDate: Date? = nil, toDate: Date? = nil, schedules: [Schedule]) {
        self.title = title
        self.description = description
        self.fromDate = fromDate
        self.toDate = toDate
        self.schedules = schedules
        
        setFromDate()
        setToDate()
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

extension TravelPlan {
    func toData() -> TravelPlanDTO {
        TravelPlanDTO(
            title: title,
            description: description,
            schedules: schedules.map { $0.toData() }
        )
    }
}

extension TravelPlan: Equatable {
    static func == (lhs: TravelPlan, rhs: TravelPlan) -> Bool {
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.fromDate == rhs.fromDate &&
        lhs.toDate == rhs.toDate &&
        lhs.schedules == rhs.schedules
    }
}
