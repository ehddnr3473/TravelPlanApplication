//
//  TravelPlanViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import Combine
import Domain
import FirebasePlatform

private protocol TravelPlanViewModel: AnyObject {
    // Input(Model update) -> Output(Model information)
    func create(_ travelPlan: YTTravelPlan) async throws
    func read() async throws
    func update(at index: Int, _ travelPlan: YTTravelPlan) async throws
    func delete(_ index: Int) async throws
    func swapTravelPlans(at source: Int, to destination: Int) async throws
}

final class ConcreteTravelPlanViewModel: TravelPlanViewModel {
    private(set) var model = CurrentValueSubject<[YTTravelPlan], Never>([])
    private let useCaseProvider: TravelPlanUseCaseProvider
    
    init(_ useCaseProvider: TravelPlanUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func create(_ travelPlan: YTTravelPlan) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: model.value.endIndex, travelPlan: travelPlan.toDomain())
        model.value.append(travelPlan)
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideTravelPlanReadUseCase()
        model.send(try await readUseCase.execute().map { YTTravelPlan(travelPlan: $0) })
    }
    
    func update(at index: Int, _ travelPlan: YTTravelPlan) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: index, travelPlan: travelPlan.toDomain())
        model.value[index] = travelPlan
    }
    
    func delete(_ index: Int) async throws {
        let deleteUseCase = useCaseProvider.provideTravelPlanDeleteUseCase()
        try await deleteUseCase.execute(at: index)
        model.value.remove(at: index)
    }
    
    func swapTravelPlans(at source: Int, to destination: Int) async throws {
        let swapUseCase = useCaseProvider.provideTravelPlanSwapUseCase()
        do {
            try await swapUseCase.execute(
                TravelPlanSwapBox(
                    source: source,
                    destination: destination,
                    sourceTravelPlan: model.value[source].toDomain(),
                    destinationTravelPlan: model.value[source].toDomain()
                )
            )
            // swap에 성공했다면, 모델 업데이트
            model.value.swapAt(source, destination)
        } catch {
            /*
             swap(총 2번의 upload(at:travelPlanDTO:))을 하며 sourceTravelPlan, destinationTravelPlan 둘 중 하나의,
             또는 둘 다의 업로드에 실패했다면, 초기 상태로 돌리기 위해 각각 update(at:_:) 수행
             */
            try? await update(at: source, model.value[source])
            try? await update(at: destination, model.value[destination])
            throw TravelPlanRepositoryError.swapError
        }
    }
}
