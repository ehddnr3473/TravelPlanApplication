//
//  TravelPlan.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation

/// Plan Model
struct TravelPlan {
    var plans: [Plan]
    
    func title(_ index: Int) -> String {
        plans[index].title
    }
    
    func date(_ index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = TextConstants.dateFormat
        if let date = plans[index].date {
            return dateFormatter.string(from: date)
        } else {
            return TextConstants.nilDate
        }
    }
}

private enum TextConstants {
    static let dateFormat = "yyyy.MM.dd"
    static let nilDate = "날짜 미지정"
}
