//
//  TravelPlaner.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import Combine
import UIKit

/// Plan View Model Protocol
protocol PlanConfigurable: AnyObject {
    // input
    func delete(_ index: Int)
    
    // output
    var publisher: PassthroughSubject<Void, Never> { get set }
    var planCount: Int { get }
    func title(_ index: Int) -> String
    func date(_ index: Int) -> String
    func description(_ index: Int) -> String
    
    init(_ useCase: DefaultPlanUseCase)
}

/// TravelPlan View Model
final class TravelPlaner: PlanConfigurable {
    private let useCase: DefaultPlanUseCase
    var publisher = PassthroughSubject<Void, Never>()
    
    var planCount: Int {
        useCase.planCount
    }
    
    required init(_ useCase: DefaultPlanUseCase) {
        self.useCase = useCase
    }
    
    func title(_ index: Int) -> String {
        useCase.title(index)
    }
    
    func date(_ index: Int) -> String {
        useCase.date(index)
    }
    
    func description(_ index: Int) -> String {
        useCase.description(index)
    }
    
    func delete(_ index: Int) {
        Task { await useCase.delete(index) }
    }
    
    func setUpWritingView(at index: Int? = nil, _ writingStyle: WritingStyle) -> UINavigationController {
        useCase.setUpWritingView(at: index, writingStyle)
    }
}
