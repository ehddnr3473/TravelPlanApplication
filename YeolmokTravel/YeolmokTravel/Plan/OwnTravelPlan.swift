//
//  TravelPlan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// TravelPlan Model
struct OwnTravelPlan {
    var travelPlans: [TravelPlan]
    
    var count: Int {
        travelPlans.count
    }
    
    func title(_ index: Int) -> String {
        travelPlans[index].title
    }
    
    mutating func appendPlan(_ plan: TravelPlan) {
        travelPlans.append(plan)
    }
    
    mutating func modifyPlan(at index: Int, _ plan: TravelPlan) {
        travelPlans[index] = plan
    }
    
    func date(_ index: Int) -> String {
        travelPlans[index].date
    }
    
    func description(_ index: Int) -> String {
        if let description = travelPlans[index].description {
            return description
        } else {
            return ""
        }
    }
}
