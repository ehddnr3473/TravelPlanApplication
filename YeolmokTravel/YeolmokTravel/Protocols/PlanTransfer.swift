//
//  PlanTransfer.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

protocol PlanTransfer: AnyObject {
    func writingHandler(_ plan: some Plan, _ index: Int?)
}
