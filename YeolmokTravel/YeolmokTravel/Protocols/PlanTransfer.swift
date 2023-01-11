//
//  PlanTransfer.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/11.
//

import Foundation

protocol PlanTransfer: AnyObject {
    func writingHandler(_ plan: some Plan, _ index: Int?)
}
