//
//  Plan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/21.
//

import Foundation

protocol Plan: Equatable {
    var title: String { get set }
    var description: String? { get set }
    var fromDate: Date? { get set }
    var toDate: Date? { get set }
}
