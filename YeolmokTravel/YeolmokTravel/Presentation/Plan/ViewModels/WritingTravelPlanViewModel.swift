//
//  WritingTravelViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/24.
//

import Foundation
import Combine
import CoreLocation

enum WritingTravelPlanError: String, Error {
    case emptyTitle = "제목을 작성해주세요."
}

private protocol WritingTravelPlanViewModel: AnyObject {
    associatedtype TextInput
    
    func subscribeText(input: TextInput)
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
    
    func updateSchedule(at index: Int, _ schedule: Schedule) {
        model.value.schedules[index] = schedule
    }
    
    func createSchedule(_ schedule: Schedule) {
        model.value.schedules.append(schedule)
    }
    
    func removeSchedule(at index: Int) {
        model.value.schedules.remove(at: index)
    }
    
    func swapSchedules(at source: Int, to destination: Int) {
        model.value.schedules.swapAt(source, destination)
    }
    
    func setPlan() {
        travelPlanTracker.setPlan(TravelPlan(title: title,
                                             description: description,
                                             schedules: model.value.schedules))
    }
    
    func isValidSave() throws {
        guard title.count > 0 else { throw WritingTravelPlanError.emptyTitle }
    }
}

extension ConcreteWritingTravelPlanViewModel: WritingTravelPlanViewModel {
    struct TextInput {
        let titlePublisher: AnyPublisher<String, Never>
        let descriptionPublisher: AnyPublisher<String, Never>
    }
    
    func subscribeText(input: TextInput) {
        input.titlePublisher
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
        
        input.descriptionPublisher
            .assign(to: \.description, on: self)
            .store(in: &subscriptions)
    }
}
