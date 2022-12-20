//
//  Plan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/21.
//

import Foundation

protocol Plan {
    var title: String { get set }
    var description: String? { get set }
    var date: Date? { get set }
}
