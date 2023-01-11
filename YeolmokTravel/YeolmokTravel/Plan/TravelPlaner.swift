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
    // output
    var publisher: PassthroughSubject<Void, Never> { get set }
    var planCount: Int { get }
    func title(_ index: Int) -> String
    func date(_ index: Int) -> String
    func description(_ index: Int) -> String
    func setUpWritingView(at index: Int?, _ writingStyle: WritingStyle) -> UINavigationController
    
    // input
    func delete(_ index: Int)
    
    init(_ model: OwnTravelPlan)
}

/// TravelPlan View Model
final class TravelPlaner: ObservableObject, PlanConfigurable, PlanTransfer {
    var model: OwnTravelPlan
    
    var publisher = PassthroughSubject<Void, Never>()
    
    var planCount: Int {
        model.travelPlans.count
    }
    
    required init(_ model: OwnTravelPlan) {
        self.model = model
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
        Task { await model.delete(at: index) }
    }
    
    // input
    func writingHandler(_ plan: some Plan, _ index: Int?) {
        guard let plan = plan as? TravelPlan else { return }
        if let index = index {
            model.update(at: index, plan)
            Task { await model.write(at: index) }
            publisher.send()
        } else {
            model.add(plan)
            Task { await model.write(at: nil) }
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
        writingView.writingStyle = writingStyle
        let navigationController = UINavigationController(rootViewController: writingView)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
