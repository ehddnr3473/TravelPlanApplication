//
//  DefaultPlanUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import UIKit

final class DefaultPlanUseCase {
    private var model: OwnTravelPlan
    private let repository = PlanRepository()
    
    init(model: OwnTravelPlan) {
        self.model = model
    }
    
    var planCount: Int {
        model.travelPlans.count
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
    
    func delete(_ index: Int) async {
        model.delete(at: index)
        await repository.delete(at: index)
    }
    
    func update(at index: Int, _ plan: TravelPlan) {
        model.update(at: index, plan)
        Task { await write(at: index) }
    }
    
    func add(_ plan: TravelPlan) {
        model.add(plan)
        Task { await write(at: nil) }
    }
    
    func write(at index: Int?) async {
        if let index = index {
            await repository.write(at: index, model.travelPlans[index].toData())
        } else {
            let lastIndex = model.travelPlans.count - NumberConstants.one
            await repository.write(at: lastIndex, model.travelPlans[lastIndex].toData())
        }
    }
}

extension DefaultPlanUseCase: PlanTransfer {
    func writingHandler(_ plan: some Plan, _ index: Int?) {
        guard let plan = plan as? TravelPlan else { return }
        if let index = index {
            update(at: index, plan)
        } else {
            add(plan)
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

private enum NumberConstants {
    static let one = 1
}
