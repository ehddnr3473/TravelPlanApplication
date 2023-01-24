//
//  TravelPlan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// TravelPlan Model
struct OwnTravelPlan {
    private(set) var travelPlans: [TravelPlan]
    
    mutating func add(_ plan: TravelPlan) {
        travelPlans.append(plan)
    }
    
    mutating func update(at index: Int, _ plan: TravelPlan) {
        travelPlans[index] = plan
    }
    
    mutating func delete(at index: Int) {
        travelPlans.remove(at: index)
    }
}
