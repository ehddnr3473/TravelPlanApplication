//
//  TravelPlanSwapUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/12.
//

import Foundation

struct TravelPlanSwapBox {
    let source: Int
    let destination: Int
    let sourceTravelPlan: TravelPlan
    let destinationTravelPlan: TravelPlan
}

protocol TravelPlanSwapUseCase {
    /// 데이터베이스에서 순서를 swap하는 유스케이스 메서드
    /// - sourceTravelPlan과 destinationTravelPlan의 업로드 성공시 모델 업데이트
    /// - 둘 중 하나라도 실패시, error throw
    /// - Parameter travelPlanSwapBox: swap을 수행하기 위한 데이터 묶음
    func execute(_ travelPlanSwapBox: TravelPlanSwapBox) async throws
}

struct ConcreteTravelPlanSwapUseCase: TravelPlanSwapUseCase {
    private let travelPlanRepository: AbstractTravelPlanRepository
    
    init(_ travelPlanRepository: AbstractTravelPlanRepository) {
        self.travelPlanRepository = travelPlanRepository
    }
    
    func execute(_ travelPlanSwapBox: TravelPlanSwapBox) async throws {
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in // rethrows
            taskGroup.addTask { [self] in
                try await travelPlanRepository.upload(
                    at: travelPlanSwapBox.source,
                    travelPlanDTO: travelPlanSwapBox.sourceTravelPlan.toData()
                )
            }
            
            taskGroup.addTask { [self] in
                try await travelPlanRepository.upload(
                    at: travelPlanSwapBox.destination,
                    travelPlanDTO: travelPlanSwapBox.destinationTravelPlan.toData()
                )
            }
            
            for try await _ in taskGroup { }
        }
    }
}
