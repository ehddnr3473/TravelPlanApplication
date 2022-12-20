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
                                   date: Date(),
                                   schedules: [Schedule(title: "삿포로",
                                                        description: "눈밭 뒹굴기",
                                                        date: nil)])
    var plans: [Plan]
    
    func title(_ index: Int) -> String {
        plans[index].title
    }
    
    func date(_ index: Int) -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.string(from: plans[index].date)
    }
}
