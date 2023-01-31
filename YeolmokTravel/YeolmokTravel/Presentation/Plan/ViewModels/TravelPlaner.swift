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
fileprivate protocol PlanConfigurable: AnyObject {
    // input
    func delete(_ index: Int)
    
    // output
    var publisher: PassthroughSubject<Void, Never> { get set }
    var planCount: Int { get }
    func title(_ index: Int) -> String
    func date(_ index: Int) -> String
    func description(_ index: Int) -> String
    
    init(_ model: OwnTravelPlan, _ planControllableUseCase: ModelControllableUsable, _ planPostsUseCase: TextPostsUsable)
}

/// TravelPlan View Model
final class TravelPlaner: PlanConfigurable {
    private var model: OwnTravelPlan
    private let planControllableUseCase: ModelControllableUsable
    private let planPostsUseCase: TextPostsUsable
    
    var publisher = PassthroughSubject<Void, Never>()
    
    var planCount: Int {
        model.travelPlans.count
    }
    
    required init(_ model: OwnTravelPlan, _ planControllableUseCase: ModelControllableUsable, _ planPostsUseCase: TextPostsUsable) {
        self.model = model
        self.planControllableUseCase = planControllableUseCase
        self.planPostsUseCase = planPostsUseCase
    }
    
    func title(_ index: Int) -> String {
        model.travelPlans[index].title
    }
    
    func date(_ index: Int) -> String {
        model.travelPlans[index].date
    }
    
    func description(_ index: Int) -> String {
        model.travelPlans[index].description
    }
    
    func delete(_ index: Int) {
        planControllableUseCase.delete(index)
        Task { planPostsUseCase.delete(at: index) }
    }
}

extension TravelPlaner: PlanTransfer {
    func writingHandler(_ plan: some Plan, _ index: Int?) {
        guard let plan = plan as? TravelPlan else { return }
        if let index = index {
            planControllableUseCase.update(at: index, plan)
            planPostsUseCase.upload(at: index, model: plan)
            publisher.send()
        } else {
            planControllableUseCase.add(plan)
            let lastIndex = model.travelPlans.count - NumberConstants.one
            planPostsUseCase.upload(at: lastIndex, model: model.travelPlans[lastIndex])
            publisher.send()
        }
    }
    
    // 여행 계획을 작성(수정, 추가)하기 위해 프레젠테이션할 ViewController 반환
    func setUpWritingView(at index: Int? = nil, _ writingStyle: WritingStyle) -> UINavigationController {
        let writingView = WritingTravelPlanViewController()
        switch writingStyle {
        case .add:
            let model = TravelPlan(title: "", description: "", schedules: [])
            writingView.model = model
            writingView.addDelegate = self
        case .edit:
            let model = model.travelPlans[index!]
            writingView.model = model
            writingView.editDelegate = self
            writingView.planListIndex = index
        }
        let viewModel = WritingPlanViewModel()
        writingView.viewModel = viewModel
        writingView.writingStyle = writingStyle
        let navigationController = UINavigationController(rootViewController: writingView)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}

private enum NumberConstants {
    static let one = 1
}
