//
//  PlanConfigurable.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// Plan View Model Protocol
protocol PlanConfigurable {
    var model: TravelPlan { get set }
    func title(_ index: Int) -> String
    func date(_ index: Int) -> String
    func setUpAddPlanView() -> Writable
    func setUpModifyPlanView(at index: Int) -> Writable
    
    init(_ model: TravelPlan)
}