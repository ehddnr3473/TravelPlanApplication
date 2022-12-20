//
//  Schedule.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

struct Schedule: Plan, Equatable {
    var title: String
    var description: String?
    var date: Date?
}
