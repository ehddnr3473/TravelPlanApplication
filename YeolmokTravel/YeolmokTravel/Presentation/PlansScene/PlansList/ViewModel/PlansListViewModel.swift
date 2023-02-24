//
//  PlansListViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import Combine
import Domain
import FirebasePlatform

protocol PlansListViewModelInput {
    func create(_ plan: Plan) async throws
    func update(at index: Int, _ plan: Plan) async throws
    func delete(_ index: Int) async throws
    func swapTravelPlans(at source: Int, to destination: Int) async throws
}

protocol PlansListViewModelOutput {
    var plans: CurrentValueSubject<[Plan], Never> { get }
    func read() async throws // viewDidLoad
}

protocol PlansListViewModel: PlansListViewModelInput, PlansListViewModelOutput, AnyObject {}

final class DefaultPlansListViewModel: PlansListViewModel {
    private let useCaseProvider: TravelPlanUseCaseProvider
    // MARK: - Output
    let plans = CurrentValueSubject<[Plan], Never>([])
    
    // MARK: - Init
    init(_ useCaseProvider: TravelPlanUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideTravelPlanReadUseCase()
        plans.send(try await readUseCase.execute().map { Plan(travelPlan: $0) })
    }
}

// MARK: - Input
extension DefaultPlansListViewModel {
    func create(_ plan: Plan) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: plans.value.endIndex, travelPlan: plan.toDomain())
        plans.value.append(plan)
    }
    
    func update(at index: Int, _ plan: Plan) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: index, travelPlan: plan.toDomain())
        plans.value[index] = plan
    }
    
    func delete(_ index: Int) async throws {
        let deleteUseCase = useCaseProvider.provideTravelPlanDeleteUseCase()
        try await deleteUseCase.execute(at: index)
        plans.value.remove(at: index)
    }
    
    func swapTravelPlans(at source: Int, to destination: Int) async throws {
        let swapUseCase = useCaseProvider.provideTravelPlanSwapUseCase()
        do {
            try await swapUseCase.execute(
                TravelPlanSwapBox(
                    source: source,
                    destination: destination,
                    sourceTravelPlan: plans.value[source].toDomain(),
                    destinationTravelPlan: plans.value[source].toDomain()
                )
            )
            // swap에 성공했다면, 업데이트
            plans.value.swapAt(source, destination)
        } catch {
            /*
             swap(총 2번의 upload(at:travelPlanDTO:))을 하며 sourceTravelPlan, destinationTravelPlan 둘 중 하나의,
             또는 둘 다의 업로드에 실패했다면, 초기 상태로 돌리기 위해 각각 update(at:_:) 수행
             */
            try? await update(at: source, plans.value[source])
            try? await update(at: destination, plans.value[destination])
            throw TravelPlanRepositoryError.swapError
        }
    }
}
