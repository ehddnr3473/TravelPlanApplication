//
//  TravelPlaner.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/20.
//

import Foundation
import Combine

/// TravelPlan View Model
final class TravelPlaner: ObservableObject, PlanConfigurable, PlanTransfer {
    var model: OwnTravelPlan
    
    let publisher = PassthroughSubject<Void, Never>()
    
    var planCount: Int {
        model.count
    }
    
    required init(_ model: OwnTravelPlan) {
        self.model = model
    }
    
    func title(_ index: Int) -> String {
        model.title(index)
    }
    
    func date(_ index: Int) -> String {
        model.date(index)
    }
    
    func description(_ index: Int) -> String {
        model.description(index)
    }
    
    func writingHandler(_ plan: some Plan, _ index: Int?) {
        guard let plan = plan as? TravelPlan else { return }
        if let index = index {
            model.modifyPlan(at: index, plan)
            Task { await model.write(at: index) }
            publisher.send()
        } else {
            model.appendPlan(plan)
            Task { await model.write(at: nil) }
            publisher.send()
        }
    }
    
    // 여행 계획을 추가하기 위해 프레젠테이션할 ViewController 반환
    func setUpAddTravelPlanView() -> WritingTravelPlanViewController {
        let model = TravelPlan(title: "", description: "", schedules: [])
        let writingTravelPlanViewController = WritingTravelPlanViewController()
        writingTravelPlanViewController.model = model
        writingTravelPlanViewController.writingStyle = .add
        writingTravelPlanViewController.addDelegate = self
        writingTravelPlanViewController.modalPresentationStyle = .fullScreen
        
        return writingTravelPlanViewController
    }
    
    // 여행 계획을 수정하기 위해 프레젠테이션할 ViewController 반환
    func setUpModifyTravelPlanView(at index: Int) -> WritingTravelPlanViewController {
        let model = model.travelPlans[index]
        let writingTravelPlanViewController = WritingTravelPlanViewController()
        writingTravelPlanViewController.model = model
        writingTravelPlanViewController.writingStyle = .edit
        writingTravelPlanViewController.editDelegate = self
        writingTravelPlanViewController.planListIndex = index
        writingTravelPlanViewController.modalPresentationStyle = .fullScreen
        return writingTravelPlanViewController
    }
}
