//
//  TravelPlan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// Plan Model
struct TravelPlan {
    static let myTravelPlan = Plan(title: "일본",
                                   date: Date())
    var plans: [Plan]
    
    func title(_ index: Int) -> String {
        plans[index].title
    }
    
    func date(_ index: Int) -> String {
        let dateFormatter = DateFormatter()
        if let date = plans[index].date {
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
}
