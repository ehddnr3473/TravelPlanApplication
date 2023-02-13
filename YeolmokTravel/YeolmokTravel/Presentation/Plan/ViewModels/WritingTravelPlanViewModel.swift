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
    // Binding
    associatedtype TextInput
    func subscribeText(input: TextInput)
    
    // Input(Model update) -> Output(Model information)
    func createSchedule(_ schedule: Schedule)
    func updateSchedule(at index: Int, _ schedule: Schedule)
    func deleteSchedule(at index: Int)
    func swapSchedules(at source: Int, to destination: Int)
    func setTravelPlanTracker()
    
    // Output
    var calculateScrollViewContainerHeight: CGFloat { get }
    func isValidSave() throws
}

final class ConcreteWritingTravelPlanViewModel: WritingTravelPlanViewModel {
    private(set) var travelPlanTracker: TravelPlanTracker
    private(set) var model: CurrentValueSubject<TravelPlan, Never>
    
    private var subscriptions = Set<AnyCancellable>()
    
    var calculateScrollViewContainerHeight: CGFloat {
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
    
    init(_ model: TravelPlan) {
        self.model = CurrentValueSubject<TravelPlan, Never>(model)
        self.travelPlanTracker = TravelPlanTracker(model)
    }
    
    deinit {
        print("deinit: WritingTravelPlanViewModel")
    }
    
    func createSchedule(_ schedule: Schedule) {
        model.value.schedules.append(schedule)
    }
    
    func updateSchedule(at index: Int, _ schedule: Schedule) {
        model.value.schedules[index] = schedule
    }
    
    func deleteSchedule(at index: Int) {
        model.value.schedules.remove(at: index)
    }
    
    func swapSchedules(at source: Int, to destination: Int) {
        model.value.schedules.swapAt(source, destination)
    }
    
    func setTravelPlanTracker() {
        travelPlanTracker.travelPlan = TravelPlan(title: model.value.title,
                                                  description: model.value.description,
                                                  schedules: model.value.schedules)
    }
    
    func isValidSave() throws {
        guard model.value.title.count > 0 else { throw WritingTravelPlanError.emptyTitle }
    }
}

extension ConcreteWritingTravelPlanViewModel {
    struct TextInput {
        let titlePublisher: AnyPublisher<String, Never>
        let descriptionPublisher: AnyPublisher<String, Never>
    }
    
    func subscribeText(input: TextInput) {
        input.titlePublisher
            .assign(to: \.model.value.title, on: self)
            .store(in: &subscriptions)
        
        input.descriptionPublisher
            .assign(to: \.model.value.description, on: self)
            .store(in: &subscriptions)
    }
}
