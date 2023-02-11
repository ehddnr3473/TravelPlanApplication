//
//  TravelPlanViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import Combine

private protocol TravelPlanViewModel: AnyObject {
    // Input(Model update) -> Output(Model information)
    func create(_ travelPlan: TravelPlan) async throws
    func read() async throws
    func update(at index: Int, _ travelPlan: TravelPlan) async throws
    func delete(_ index: Int) async throws
    func swapTravelPlans(at source: Int, to destination: Int) async throws
    
    init(_ useCaseProvider: TravelPlanUseCaseProvider)
}

final class ConcreteTravelPlanViewModel: TravelPlanViewModel {
    private(set) var model = CurrentValueSubject<OwnTravelPlan, Never>(OwnTravelPlan(travelPlans: []))
    private let useCaseProvider: TravelPlanUseCaseProvider
    
    required init(_ useCaseProvider: TravelPlanUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func create(_ travelPlan: TravelPlan) async throws {
        let lastIndex = model.value.travelPlans.count - NumberConstants.one
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: lastIndex, travelPlan: model.value.travelPlans[lastIndex])
        model.value.create(travelPlan)
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideTravelPlanReadUseCase()
        model.send(OwnTravelPlan(travelPlans: try await readUseCase.execute()))
    }
    
    func update(at index: Int, _ travelPlan: TravelPlan) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: index, travelPlan: travelPlan)
        model.value.update(at: index, travelPlan)
    }
    
    func delete(_ index: Int) async throws {
        let deleteUseCase = useCaseProvider.provideTravelPlanDeleteUseCase()
        try await deleteUseCase.execute(at: index)
        model.value.delete(at: index)
    }
    
    func swapTravelPlans(at source: Int, to destination: Int) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: source, travelPlan: model.value.travelPlans[source])
        try await uploadUseCase.execute(at: source, travelPlan: model.value.travelPlans[destination])
        model.value.swapTravelPlans(at: source, to: destination)
    }
}

private enum NumberConstants {
    static let one = 1
}
