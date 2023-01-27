//
//  TravelPlan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// TravelPlan Model
final class OwnTravelPlan {
    private(set) var travelPlans: [TravelPlan]
    
    init(travelPlans: [TravelPlan]) {
        self.travelPlans = travelPlans
    }
    
    func add(_ plan: TravelPlan) {
        travelPlans.append(plan)
    }
    
    func update(at index: Int, _ plan: TravelPlan) {
        travelPlans[index] = plan
    }
    
    func delete(at index: Int) {
        travelPlans.remove(at: index)
    }
}
