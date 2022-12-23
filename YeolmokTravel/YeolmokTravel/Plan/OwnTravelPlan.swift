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
    var repository = PlanRepository()
    
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
    
    func write(at index: Int?) async {
        if let index = index {
            await repository.writeTravelPlans(at: index, travelPlans[index])
        } else {
            let lastIndex = travelPlans.count - NumberConstants.one
            await repository.writeTravelPlans(at: lastIndex, travelPlans[lastIndex])
        }
    }
}

private enum NumberConstants {
    static let one = 1
}
