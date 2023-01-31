//
//  PlanControllableUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import UIKit

/// OwnTravelPlan 모델을 직접 조작하는 use case
final class PlanControllableUseCase: ModelControlUsable {
    private var plans: OwnTravelPlan
    
    init(model: OwnTravelPlan) {
        plans = model
    }
    
    var count: Int {
        plans.travelPlans.count
    }
    
    func query(_ index: Int) -> Model {
        plans.travelPlans[index]
    }
    
    func add(_ model: Model) {
        guard let plan = model as? TravelPlan else { return }
        plans.add(plan)
    }
    
    func update(at index: Int, _ model: Model) {
        guard let plan = model as? TravelPlan else { return }
        plans.update(at: index, plan)
    }
    
    func delete(_ index: Int) {
        plans.delete(at: index)
    }
}
