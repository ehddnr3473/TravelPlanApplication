//
//  TravelPlaner.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// Plan View Model
final class TravelPlaner: PlanConfigurable {
    var model: TravelPlan
    
    required init(_ model: TravelPlan) {
        self.model = model
    }
    
    func title(_ index: Int) -> String {
        model.title(index)
    }
    
    func date(_ index: Int) -> String {
        model.date(index)
    }
}
