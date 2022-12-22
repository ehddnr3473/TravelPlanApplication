//
//  WritablePlan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/21.
//

import Foundation

/// Writing ViewControllers를 위한 Model
/// For Schdule, TravelPlan
struct WritablePlan<T: Plan> {
    var plan: T
    var initialPlan: T
    
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
    
    var titleIsEmpty: Bool {
        if plan.title == "" {
            return true
        } else {
            return false
        }
    }
    
    // update
    mutating func setPlan(_ title: String, _ description: String, _ fromData: Date? = nil, _ toDate: Date? = nil) {
        plan.title = title
        if description == "" {
            plan.description = nil
        } else {
            plan.description = description
        }
        plan.fromDate = fromData
        plan.toDate = toDate
    }
}
