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
    var fromDate: Date?
    var toDate: Date?
    var schedules: [Schedule] {
        didSet {
            setFromDate()
            setToDate()
        }
    }
    
    var schedulesCount: Int {
        schedules.count
    }
    
    var date: String {
        if let fromDate = fromDate, let toDate = toDate {
            if fromDate == toDate {
                return DateUtilities.dateFormatter.string(from: fromDate)
            } else {
                return "\(DateUtilities.dateFormatter.string(from: fromDate)) ~ \(DateUtilities.dateFormatter.string(from: toDate))"
            }
        } else {
            return DateUtilities.nilDateText
        }
    }
    
    mutating func setFromDate() {
        let scheduleHavingMinFromDate = schedules.min { first, second in
            if let first = first.fromDate, let second = second.fromDate {
                return first < second
            } else if let _ = first.fromDate {
                return true
            } else if let _ = second.fromDate {
                return true
            } else {
                return false
            }
        }
        fromDate = scheduleHavingMinFromDate?.fromDate
        print(fromDate)
    }
    
    mutating func setToDate() {
        let scheduleHavingMaxToDate = schedules.max { first, second in
            if let first = first.toDate, let second = second.toDate {
                return first < second
            } else if let _ = first.toDate {
                return true
            } else if let _ = second.toDate {
                return true
            } else {
                return false
            }
        }
        toDate = scheduleHavingMaxToDate?.toDate
        print(toDate)
    }
    
    mutating func editSchedule(at index: Int, _ schedule: Schedule) {
        schedules[index] = schedule
    }
    
    mutating func addSchedule(_ schedule: Schedule) {
        schedules.append(schedule)
    }
}
