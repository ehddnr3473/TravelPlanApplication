//
//  PlanRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import FirebaseFirestore

/// Plan 관련 Firebase Firestore 연동
struct PlanRepository {
    private var database = Firestore.firestore()
    
    func write(at index: Int, _ travelPlan: TravelPlan) async {
        try? await database.collection(DatabasePath.plans).document("\(index)").setData([
            Key.title: travelPlan.title,
            Key.description: travelPlan.description
        ])
        
        for scheduleIndex in travelPlan.schedules.indices {
            try? await database.collection(DatabasePath.plans)
                .document("\(index)").collection(DocumentConstants.schedulesCollection).document("\(scheduleIndex)")
                .setData([
                    // Key-Value Pair
                    Key.title:
                        travelPlan.schedules[scheduleIndex].title,
                    Key.description:
                        travelPlan.schedules[scheduleIndex].description,
                    Key.fromDate:
                        DateConverter.dateToString(travelPlan.schedules[scheduleIndex].fromDate),
                    Key.toDate:
                        DateConverter.dateToString(travelPlan.schedules[scheduleIndex].toDate)
                ])
        }
    }
    
    // Firebase에서 다운로드한 데이터로 실제 사용할 [TravelPlan]을 생성해서 반환
    func read() async -> [TravelPlan] {
        var travelPlans = [TravelPlan]()
        let travelPlansSnapshot = try? await database.collection(DatabasePath.plans).getDocuments()
        var documentIndex = NumberConstants.zero
        
        for document in travelPlansSnapshot!.documents {
            let data = document.data()
            travelPlans.append(self.createTravelPlan(data))
            let scheduleSnapshot = try? await database.collection(DatabasePath.plans)
                .document("\(documentIndex)").collection(DocumentConstants.schedulesCollection).getDocuments()
            
            for documentation in scheduleSnapshot!.documents {
                travelPlans[documentIndex].schedules.append(self.createSchedule(documentation.data()))
            }
            documentIndex += NumberConstants.one
        }
        return travelPlans
    }
    
    // Firebase에서 다운로드한 데이터로 TravelPlan을 생성해서 반환
    private func createTravelPlan(_ data: Dictionary<String, Any>) -> TravelPlan {
        TravelPlan(title: data[Key.title] as! String,
                   description: data[Key.description] as! String,
                   schedules: [])
    }
    
    // Firebase에서 다운로드한 데이터로 Schedule을 생성해서 반환
    private func createSchedule(_ data: Dictionary<String, Any>) -> Schedule {
        if let fromDate = data[Key.fromDate] as? String, let toDate = data[Key.toDate] as? String {
            return Schedule(title: data[Key.title] as! String,
                            description: data[Key.description] as! String,
                            fromDate: DateConverter.stringToDate(fromDate),
                            toDate: DateConverter.stringToDate(toDate))
        } else {
            return Schedule(title: data[Key.title] as! String,
                            description: data[Key.description] as! String)
        }
    }
}

private enum NumberConstants {
    static let zero = 0
    static let one = 1
}
private enum DocumentConstants {
    static let schedulesCollection = "schedules"
}

private enum Key {
    static let title = "title"
    static let description = "description"
    static let fromDate = "fromDate"
    static let toDate = "toDate"
}
