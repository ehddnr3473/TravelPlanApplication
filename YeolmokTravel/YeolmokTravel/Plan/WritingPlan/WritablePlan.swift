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
