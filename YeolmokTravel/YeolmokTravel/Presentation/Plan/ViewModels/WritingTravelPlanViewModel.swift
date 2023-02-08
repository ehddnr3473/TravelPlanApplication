//
//  WritingTravelViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine
import CoreLocation

private protocol WritingTravelPlanViewModelType: AnyObject {
    associatedtype TextInput
    associatedtype TextOutput
    
    func transform(input: TextInput) -> TextOutput
}

final class WritingTravelPlanViewModel {
    private(set) var planTracker: PlanTracker<TravelPlan>
    private(set) var model: TravelPlan
    
    private var title: String
    private var description: String
    private(set) var coordinatesPublisher = PassthroughSubject<[CLLocationCoordinate2D], Never>()
    private var subscriptions = Set<AnyCancellable>()
    
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
    
    var scrollViewContainerheight: CGFloat {
        if schedulesCount == 0 {
            return AppLayoutConstants.writingTravelPlanViewHeight +
            Double(schedulesCount) * AppLayoutConstants.cellHeight +
            AppLayoutConstants.largeSpacing * 2
        } else {
            return AppLayoutConstants.writingTravelPlanViewHeight +
            Double(schedulesCount) * AppLayoutConstants.cellHeight +
            AppLayoutConstants.mapViewHeight +
            AppLayoutConstants.largeFontSize +
            AppLayoutConstants.spacing +
            AppLayoutConstants.buttonHeight +
            AppLayoutConstants.largeSpacing * 3
        }
    }
    
    init(_ model: TravelPlan) {
        self.model = model
        self.planTracker = PlanTracker(model)
        self.title = model.title
        self.description = model.description
    }
    
    deinit {
        print("deinit: WritingTravelPlanViewModel")
    }
    
    func setTravelPlan() {
        model.setTravelPlanText(title, description)
    }
    
    func editSchedule(at index: Int, _ schedule: Schedule) {
        model.editSchedule(at: index, schedule)
        scheduleControlCompletion()
    }
    
    func addSchedule(_ schedule: Schedule) {
        model.addSchedule(schedule)
        scheduleControlCompletion()
    }
    
    func removeSchedule(at index: Int) {
        model.removeSchedule(at: index)
        scheduleControlCompletion()
    }
    
    func swapSchedules(at source: Int, to destination: Int) {
        model.swapSchedules(at: source, to: destination)
        scheduleControlCompletion()
    }
    
    func scheduleControlCompletion() {
        coordinatesPublisher.send(coordinatesOfSchedules())
    }
    
    func coordinatesOfSchedules() -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        
        for schedule in schedules {
            coordinates.append(schedule.coordinate)
        }
        
        return coordinates
    }
    
    func setPlan() {
        planTracker.setPlan(TravelPlan(title: title,
                                       description: description,
                                       schedules: schedules))
    }
}

extension WritingTravelPlanViewModel: WritingTravelPlanViewModelType {
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
