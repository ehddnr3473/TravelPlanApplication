//
//  PlanControllableUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import UIKit

protocol ModelControllableUseCase {
    func add(_ plan: TravelPlan)
    func update(at index: Int, _ plan: TravelPlan)
    func delete(_ index: Int) async
}

/// OwnTravelPlan 모델을 직접 조작하는 유스케이스
final class PlanControllableUseCase: ModelControllableUseCase {
    private var model: OwnTravelPlan
    private let repository: FirestoreRepository
    
    init(model: OwnTravelPlan, repository: FirestoreRepository) {
        self.model = model
        self.repository = repository
    }
    
    func add(_ plan: TravelPlan) {
        model.add(plan)
    }
    
    func update(at index: Int, _ plan: TravelPlan) {
        model.update(at: index, plan)
    }
    
    func delete(_ index: Int) async {
        model.delete(at: index)
        await repository.delete(at: index)
    }
}
