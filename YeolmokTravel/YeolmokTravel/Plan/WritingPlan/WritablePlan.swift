//
//  WritablePlan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// WritableViewController Model
struct WritablePlan {
    var plan: Plan
    var initialPlan: Plan
    
    init(_ plan: Plan) {
        self.plan = plan
        self.initialPlan = plan
    }
    
    var title: String {
        plan.title
    }
    
    var date: String {
        if let date = plan.date {
            return date.formatted()
        } else {
            return ""
        }
    }
    
    var isChanged: Bool {
        if plan == initialPlan {
            return false
        } else {
            return true
        }
    }
    
    mutating func setPlan(_ title: String, _ description: String) {
        plan.title = title
        plan.description = description
    }
    
    // 제목 검증
    // 제목이 비어있다면, alert 생성 후 present. 저장하지 않음.
    // 내용(descriptionTextView)은 비어있어도 됨.
    func verifyTitleText() -> Bool {
        if plan.title == "" {
            return true
        } else {
            return false
        }
    }
}
