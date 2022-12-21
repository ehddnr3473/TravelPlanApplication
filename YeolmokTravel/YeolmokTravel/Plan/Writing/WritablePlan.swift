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
    
    var description: String {
        if let description = plan.description {
            return description
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
    
    // update
    mutating func setPlan(_ title: String, _ description: String) {
        plan.title = title
        plan.description = description
    }
    
    // 제목 검증
    // 제목이 비어있다면, alert 생성 후 present. 저장하지 않음.
    // 내용(descriptionTextView)은 비어있어도 됨.
    func titleIsEmpty() -> Bool {
        if plan.title == "" {
            return true
        } else {
            return false
        }
    }
    
    // TravelPlan's computed var
    var schedulesCount: Int? {
        guard let plan = plan as? TravelPlan else { return nil }
        return plan.schedules.count
    }
    
    func schedule(_ index: Int) -> Schedule? {
        guard let plan = plan as? TravelPlan else { return nil }
        return plan.schedules[index]
    }
    
    // edit Schedule
    mutating func appendSchdule(schedule: Schedule) {
        if var plan = plan as? TravelPlan {
            plan.schedules.append(schedule)
            self.plan = plan as! T
        }
    }
    
    mutating func modifySchdule(at index: Int, schedule: Schedule) {
        if var plan = plan as? TravelPlan {
            plan.schedules[index] = schedule
            self.plan = plan as! T
        }
    }
}
