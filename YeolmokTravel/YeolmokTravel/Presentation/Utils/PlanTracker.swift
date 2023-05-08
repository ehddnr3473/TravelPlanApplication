//
//  PlanTracker.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/21.
//

import Foundation

import struct Domain.Plan

/// Plan의 변경 사항을 추적하고 alert을 띄워주기 위한 데이터 struct
struct PlanTracker {
    var plan: Plan
    private let initialPlan: Plan
    
    init(_ plan: Plan) {
        self.plan = plan
        self.initialPlan = plan
    }
    
    var isChanged: Bool {
        if plan == initialPlan {
            return false
        } else {
            return true
        }
    }
}
