//
//  Plan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

struct Plan: Equatable {
    static func == (lhs: Plan, rhs: Plan) -> Bool {
        if lhs.title == rhs.title && lhs.date == rhs.date {
            return true
        } else {
            return false
        }
    }
    
    let title: String
    let date: Date?
//    let schedules: [Schedule]
}
