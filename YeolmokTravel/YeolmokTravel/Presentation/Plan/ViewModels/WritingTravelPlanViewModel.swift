//
//  WritingTravelViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine
import CoreLocation

private protocol WritingTravelPlanViewModel: AnyObject {
    associatedtype TextInput
    associatedtype TextOutput
    
    func transform(input: TextInput) -> TextOutput
}

final class ConcreteWritingTravelPlanViewModel {
    private(set) var travelPlanTracker: TravelPlanTracker
    private(set) var model: CurrentValueSubject<TravelPlan, Never>
    
    private var title: String
    private var description: String
    private(set) var coordinatesPublisher = PassthroughSubject<[CLLocationCoordinate2D], Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    var scrollViewContainerheight: CGFloat {
        if model.value.schedules.count == 0 {
            return AppLayoutConstants.writingTravelPlanViewHeight +
            AppLayoutConstants.largeSpacing * 2
        } else {
            return AppLayoutConstants.writingTravelPlanViewHeight +
            Double(model.value.schedules.count) * AppLayoutConstants.cellHeight +
            AppLayoutConstants.mapViewHeight +
            AppLayoutConstants.largeFontSize +
            AppLayoutConstants.spacing +
            AppLayoutConstants.buttonHeight +
            AppLayoutConstants.largeSpacing * 3
        }
    }
    
    init(_ model: CurrentValueSubject<TravelPlan, Never>) {
        self.model = model
        self.travelPlanTracker = TravelPlanTracker(model.value)
        self.title = model.value.title
        self.description = model.value.description
    }
    
    deinit {
        print("deinit: WritingTravelPlanViewModel")
    }
    
    func setTravelPlan() {
        model.value.setTravelPlanText(title, description)
    }
    
    func updateSchedule(at index: Int, _ schedule: Schedule) {
        model.value.updateSchedule(at: index, schedule)
    }
    
    func createSchedule(_ schedule: Schedule) {
        model.value.createSchedule(schedule)
    }
    
    func removeSchedule(at index: Int) {
        model.value.deleteSchedule(at: index)
    }
    
    func swapSchedules(at source: Int, to destination: Int) {
        model.value.swapSchedules(at: source, to: destination)
    }
    
    func setPlan() {
        travelPlanTracker.setPlan(TravelPlan(title: title,
                                             description: description,
                                             schedules: model.value.schedules))
    }
    
    func create(_ schedule: Schedule) {
        createSchedule(schedule)
    }
    
    func update(at index: Int, _ schedule: Schedule) {
        updateSchedule(at: index, schedule)
    }
}

extension ConcreteWritingTravelPlanViewModel: WritingTravelPlanViewModel {
    struct TextInput {
        let titlePublisher: AnyPublisher<String, Never>
        let descriptionPublisher: CurrentValueSubject<String, Never>
    }
    
    struct TextOutput {
        let buttonState: AnyPublisher<Bool, Never>
    }
    
    func transform(input: TextInput) -> TextOutput {
        let buttonStatePublisher = input.titlePublisher
            .map { [weak self] titleText in
                self?.title = titleText
                return titleText.count > 0
            }
            .eraseToAnyPublisher()
        
        input.descriptionPublisher
            .sink { [weak self] descriptionText in
                self?.description = descriptionText
            }
            .store(in: &subscriptions)
        
        return TextOutput(buttonState: buttonStatePublisher)
    }
}
