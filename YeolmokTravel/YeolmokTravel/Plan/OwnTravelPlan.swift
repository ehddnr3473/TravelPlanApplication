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
    private let repository = PlanRepository()
    
    mutating func add(_ plan: TravelPlan) {
        travelPlans.append(plan)
    }
    
    mutating func update(at index: Int, _ plan: TravelPlan) {
        travelPlans[index] = plan
    }
    
    mutating func delete(at index: Int) async {
        travelPlans.remove(at: index)
        await repository.delete(at: index)
    }
    
    func write(at index: Int?) async {
        if let index = index {
            await repository.write(at: index, travelPlans[index])
        } else {
            let lastIndex = travelPlans.count - NumberConstants.one
            await repository.write(at: lastIndex, travelPlans[lastIndex])
        }
    }
}

private enum NumberConstants {
    static let one = 1
}
