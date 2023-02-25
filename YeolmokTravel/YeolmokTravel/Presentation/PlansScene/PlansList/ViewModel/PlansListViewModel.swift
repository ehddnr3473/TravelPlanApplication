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
import CoreLocation

protocol PlansListViewModelInput {
    func create(_ plan: Plan) async throws
    func update(at index: Int, _ plan: Plan) async throws
    func delete(_ index: Int) async throws
    func swapTravelPlans(at source: Int, to destination: Int) async throws
}

protocol PlansListViewModelOutput {
    var plans: CurrentValueSubject<[Plan], Never> { get }
    func read() async throws // viewDidLoad
    func getDateString(at index: Int) -> String
}

protocol PlansListViewModel: PlansListViewModelInput, PlansListViewModelOutput, AnyObject {}

final class DefaultPlansListViewModel: PlansListViewModel {
    private let useCaseProvider: PlansUseCaseProvider
    // MARK: - Output
    let plans = CurrentValueSubject<[Plan], Never>([])
    
    // MARK: - Init
    init(_ useCaseProvider: PlansUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideReadPlansUseCase()
        plans.send(try await readUseCase.execute())
    }
    
    func getDateString(at index: Int) -> String {
        if let fromDate = plans.value[index].schedules.compactMap({ $0.fromDate }).min(),
           let toDate = plans.value[index].schedules.compactMap({ $0.toDate }).max() {
            let slicedFromDate = DateConverter.dateToString(fromDate)
            let slicedToDate = DateConverter.dateToString(toDate)
            if slicedFromDate == slicedToDate {
                return slicedFromDate
            } else {
                return "\(slicedFromDate) ~ \(slicedToDate)"
            }
        } else {
            return DateConverter.Constants.nilDateText
        }
    }
}

// MARK: - Input
extension DefaultPlansListViewModel {
    func create(_ plan: Plan) async throws {
        let uploadUseCase = useCaseProvider.provideUploadPlanUseCase()
        try await uploadUseCase.execute(at: plans.value.endIndex, plan: plan)
        plans.value.append(plan)
    }
    
    func update(at index: Int, _ plan: Plan) async throws {
        let uploadUseCase = useCaseProvider.provideUploadPlanUseCase()
        try await uploadUseCase.execute(at: index, plan: plan)
        plans.value[index] = plan
    }
    
    func delete(_ index: Int) async throws {
        let deleteUseCase = useCaseProvider.provideDeletePlanUseCase()
        try await deleteUseCase.execute(at: index)
        plans.value.remove(at: index)
    }
    
    func swapTravelPlans(at source: Int, to destination: Int) async throws {
        let swapUseCase = useCaseProvider.provideSwapPlansUseCase()
        do {
            try await swapUseCase.execute(
                SwapPlansBox(
                    source: source,
                    destination: destination,
                    sourcePlan: plans.value[source],
                    destinationPlan: plans.value[source]
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
            throw PlansRepositoryError.swapError
        }
    }
}
