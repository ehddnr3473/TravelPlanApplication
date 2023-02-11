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
    
    func create(_ travelPlan: TravelPlan) {
        travelPlans.append(travelPlan)
    }
    
    func update(at index: Int, _ travelPlan: TravelPlan) {
        travelPlans[index] = travelPlan
    }
    
    func delete(at index: Int) {
        travelPlans.remove(at: index)
    }
    
    func swapTravelPlans(at source: Int, to destination: Int) {
        travelPlans.swapAt(source, destination)
    }
}
