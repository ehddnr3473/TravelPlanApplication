//
//  PlanTracker.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/21.
//

import Foundation

/// Plan의 변경 사항을 추적하고 alert을 띄워주기 위한 데이터
struct PlanTracker<T: Plan> {
    private var plan: T
    private let initialPlan: T
    
    // 변경된 내용을 확인하기 위해 초기값 저장
    init(_ plan: T) {
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
    
    // update
    mutating func setPlan(_ plan: some Plan) {
        if let plan = plan as? T {
            self.plan = plan
        }
    }
}
