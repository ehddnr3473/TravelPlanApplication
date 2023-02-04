//
//  WritingTravelViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine

private protocol WritingTravelPlanViewModelType: AnyObject {
    associatedtype TextInput
    associatedtype TextOutput
    
    func transform(input: TextInput) -> TextOutput
}

final class WritingTravelPlanViewModel {
    private(set) var planTracker: PlanTracker<TravelPlan>
    private(set) var model: TravelPlan
    
    private var title = ""
    private var description = ""
    
    var modelTitle: String {
        model.title
    }
    
    var modelDescription: String {
        model.description
    }
    
    var schedules: [Schedule] {
        model.schedules
    }
    
    var schedulesCount: Int {
        model.schedules.count
    }
    
    init(_ model: TravelPlan) {
        self.model = model
        self.planTracker = PlanTracker(model)
    }
    
    deinit {
        print("deinit: WritingTravelPlanViewModel")
    }
    
    func setTravelPlan() {
        model.setTravelPlan(title, description)
    }
    
    func editSchedule(at index: Int, _ schedule: Schedule) {
        model.editSchedule(at: index, schedule)
    }
    
    func addSchedule(_ schedule: Schedule) {
        model.addSchedule(schedule)
    }
    
    func setPlan() {
        planTracker.setPlan(TravelPlan(title: title,
                                       description: description,
                                       schedules: schedules))
    }
}

extension WritingTravelPlanViewModel: WritingTravelPlanViewModelType {
    struct TextInput {
        let title: AnyPublisher<String, Never>
        let description: CurrentValueSubject<String, Never>
    }
    
    struct TextOutput {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    func transform(input: TextInput) -> TextOutput {
        let buttonStatePublisher = input.title.combineLatest(input.description)
            .map { [weak self] in
                self?.title = $0
                self?.description = $1
                return $0.count > 0 && $1.count > 0
            }
            .eraseToAnyPublisher()
        
        return TextOutput(buttonState: buttonStatePublisher)
    }
}
