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
    private(set) var model = CurrentValueSubject<[TravelPlan], Never>([])
    private let useCaseProvider: TravelPlanUseCaseProvider
    
    required init(_ useCaseProvider: TravelPlanUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
    }
    
    func create(_ travelPlan: TravelPlan) async throws {
        let lastIndex = model.value.endIndex - NumberConstants.one
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: lastIndex, travelPlan: model.value[lastIndex])
        model.value.append(travelPlan)
    }
    
    func read() async throws {
        let readUseCase = useCaseProvider.provideTravelPlanReadUseCase()
        model.send(try await readUseCase.execute())
    }
    
    func update(at index: Int, _ travelPlan: TravelPlan) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: index, travelPlan: travelPlan)
        model.value[index] = travelPlan
    }
    
    func delete(_ index: Int) async throws {
        let deleteUseCase = useCaseProvider.provideTravelPlanDeleteUseCase()
        try await deleteUseCase.execute(at: index)
        model.value.remove(at: index)
    }
    
    func swapTravelPlans(at source: Int, to destination: Int) async throws {
        let uploadUseCase = useCaseProvider.provideTravelPlanUploadUseCase()
        try await uploadUseCase.execute(at: source, travelPlan: model.value[source])
        try await uploadUseCase.execute(at: source, travelPlan: model.value[destination])
        model.value.swapAt(source, destination)
    }
}

private enum NumberConstants {
    static let one = 1
}
