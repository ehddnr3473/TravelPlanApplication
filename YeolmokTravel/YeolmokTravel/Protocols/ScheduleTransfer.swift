//
//  ScheduleTransfer.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

protocol ScheduleTransfer: AnyObject {
    func writingHandler(_ data: Schedule, _ index: Int?)
}
