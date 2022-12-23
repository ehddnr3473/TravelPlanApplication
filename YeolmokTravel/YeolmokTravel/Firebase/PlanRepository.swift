//
//  PlanRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/22.
//

import Foundation
import FirebaseFirestore

/// Plan 관련 Firebase Firestore 연동
struct PlanRepository {
    private var database = Firestore.firestore()
    
    func writeTravelPlans(at index: Int, _ travelPlan: TravelPlan) async {
        try? await database.collection(UserInformation.identifier).document("\(index)").setData([
            "title": "\(travelPlan.title)",
            "description": "\(travelPlan.description ?? "")"
        ])
        
        for scheduleIndex in travelPlan.schedules.indices {
            try? await database.collection(UserInformation.identifier)
                .document("\(index)").collection("schedules").document("\(scheduleIndex)")
                .setData([
                    "title": "\(travelPlan.schedules[scheduleIndex].title)",
                    "description": "\(travelPlan.schedules[scheduleIndex].description ?? "")",
                    "fromDate": "\(DateConverter.dateToString(travelPlan.schedules[scheduleIndex].fromDate))",
                    "toDate": "\(DateConverter.dateToString(travelPlan.schedules[scheduleIndex].toDate))"
                ])
        }
    }
    
    // Firebase에서 다운로드한 데이터로 실제 사용할 [TravelPlan]을 생성해서 반환
    func readTravelPlans() async -> [TravelPlan] {
        var travelPlans = [TravelPlan]()
        let travelPlanSnapshot = try? await database.collection(UserInformation.identifier).getDocuments()
        var documentIndex = NumberConstants.zero
        
        for document in travelPlanSnapshot!.documents {
            let data = document.data()
            travelPlans.append(self.createTravelPlan(data))
            let scheduleSnapshot = try? await database.collection(UserInformation.identifier)
                .document("\(documentIndex)")
                .collection("schedules")
                .getDocuments()
            
            for documentation in scheduleSnapshot!.documents {
                travelPlans[documentIndex].schedules.append(self.createSchedule(documentation.data()))
            }
            documentIndex += NumberConstants.one
        }
        return travelPlans
    }
    
    // Firebase에서 다운로드한 데이터로 TravelPlan을 생성해서 반환
    func createTravelPlan(_ data: Dictionary<String, Any>) -> TravelPlan {
        TravelPlan(title: data["title"] as! String,
                   description: data["description"] as? String,
                   schedules: [])
    }
    
    // Firebase에서 다운로드한 데이터로 Schedule을 생성해서 반환
    func createSchedule(_ data: Dictionary<String, Any>) -> Schedule {
        if let fromDate = data["fromDate"] as? String, let toDate = data["toDate"] as? String {
            return Schedule(title: data["title"] as! String,
                     description: data["description"] as? String,
                     fromDate: DateConverter.stringToDate(fromDate),
                     toDate: DateConverter.stringToDate(toDate))
        } else {
            return Schedule(title: data["title"] as! String,
                            description: data["description"] as? String)
        }
    }
}

private enum NumberConstants {
    static let zero = 0
    static let one = 1
}
