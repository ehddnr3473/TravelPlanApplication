//
//  PlanConfigurable.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// Plan View Model Protocol
protocol PlanConfigurable: AnyObject {
    var model: OwnTravelPlan { get set }
    func title(_ index: Int) -> String
    func date(_ index: Int) -> String
    func setUpAddPlanView() -> WritingTravelPlanViewController
    func setUpModifyPlanView(at index: Int) -> WritingTravelPlanViewController
    
    init(_ model: OwnTravelPlan)
}
