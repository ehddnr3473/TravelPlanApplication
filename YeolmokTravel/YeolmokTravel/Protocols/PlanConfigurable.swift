//
//  PlanConfigurable.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

protocol PlanConfigurable {
    var model: TravelPlan { get set }
    func title(_ index: Int) -> String
    func date(_ index: Int) -> String
    
    init(_ model: TravelPlan)
}
