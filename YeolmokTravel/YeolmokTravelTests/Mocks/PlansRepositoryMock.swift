//
//  PlansRepositoryMock.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/27.
//

import Foundation
import Domain
import CoreLocation

/// 테스트를 위해 작성된 가상의 저장소 클래스이므로, 실제 저장소와는 다르게 작동할 수 있음을 인지
/// 따라서 Data layer 모듈에서 적절한 테스트가 이루어진다는 전제하에 작성
/// 메서드 시그니처는 동일
final class PlansRepositoryMock: PlansRepository {
    var plans: [Plan] = [
        Plan(
            title: "title0",
            description: "description0",
            schedules: [
                Schedule(
                    title: "schedule_title0",
                    description: "schedule_desription0",
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    fromDate: Date(timeIntervalSince1970: 0),
                    toDate: Date(timeIntervalSince1970: 0)
                )
            ]
        ),
        Plan(title: "title1", description: "description1", schedules: []),
        Plan(title: "title2", description: "description2", schedules: [])
    ]
    
    func upload(plan: Plan) throws {
        if let index = plans.firstIndex(where: { $0.title == plan.title }) {
            plans[index] = plan
        } else {
            self.plans.append(plan)
        }
    }
    
    func read() async throws -> [Domain.Plan] {
        self.plans
    }
    
    func delete(key: String) async throws {
        if let index = plans.firstIndex(where: { $0.title == key }) {
            plans.remove(at: index)
        }
    }
}
