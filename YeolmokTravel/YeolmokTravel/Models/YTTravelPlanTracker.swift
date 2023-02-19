//
//  YTTravelPlanTracker.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/21.
//

import Foundation

/// YTTravelPlan의 변경 사항을 추적하고 alert을 띄워주기 위한 데이터 struct
struct YTTravelPlanTracker {
    var travelPlan: YTTravelPlan
    private let initialTravelPlan: YTTravelPlan
    
    // 변경된 내용을 확인하기 위해 초기값 저장
    init(_ travelPlan: YTTravelPlan) {
        self.travelPlan = travelPlan
        self.initialTravelPlan = travelPlan
    }
    
    var isChanged: Bool {
        if travelPlan == initialTravelPlan {
            return false
        } else {
            return true
        }
    }
}
