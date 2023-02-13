//
//  WritingScheduleViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import Foundation
import Combine
import CoreLocation

enum ScheduleError: String, Error {
    case titleError = "제목을 입력해주세요."
    case preToDateError = "시작 날짜가 종료 날짜 이후입니다."
    case fromDateError = "From 날짜를 선택해주세요."
    case toDateError = "To 날짜를 선택해주세요."
}

private protocol WritingScheduleViewModel: AnyObject {
    // Binding
    associatedtype TextInput
    associatedtype CoordinateInput
    associatedtype CoordinateOutput
    associatedtype SwitchAndDateInput
    associatedtype SwitchAndDateOutput
    
    func subscribeText(_ input: TextInput)
    func transform(_ input: CoordinateInput) -> CoordinateOutput
    func transform(_ input: SwitchAndDateInput) -> SwitchAndDateOutput
    
    // Input
    func setScheduleTracker()
    
    // Output
    func isValidSave() throws
}

final class ConcreteWritingScheduleViewModel: WritingScheduleViewModel {
    private(set) var scheduleTracker: ScheduleTracker
    private(set) var model: CurrentValueSubject<Schedule, Never>
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var verifyPreFromDate: Bool {
        guard let toDate = model.value.toDate,
                let fromDate = model.value.fromDate,
                let slicedFromDate = DateConverter.stringToDate(DateConverter.dateToString(fromDate)),
                let slicedToDate = DateConverter.stringToDate(DateConverter.dateToString(toDate)) else { return true }
        return slicedFromDate <= slicedToDate
    }
    
    init(_ model: Schedule) {
        self.model = CurrentValueSubject<Schedule, Never>(model)
        self.scheduleTracker = ScheduleTracker(model)
    }
    
    deinit {
        print("deinit: WritingScheduleViewModel")
    }
    
    func isValidSave() throws {
        if model.value.title == "" {
            throw ScheduleError.titleError
        } else if !verifyPreFromDate {
            throw ScheduleError.preToDateError
        } else if model.value.fromDate == nil && model.value.toDate != nil {
            throw ScheduleError.fromDateError
        } else if model.value.fromDate != nil && model.value.toDate == nil {
            throw ScheduleError.toDateError
        }
    }
    
    func setScheduleTracker() {
        scheduleTracker.schedule = Schedule(title: model.value.title,
                                            description: model.value.description,
                                            coordinate: model.value.coordinate,
                                            fromDate: model.value.fromDate,
                                            toDate: model.value.toDate)
    }
}

extension ConcreteWritingScheduleViewModel {
    // Title UITextField
    struct TextInput {
        let titlePublisher: AnyPublisher<String, Never>
        let descriptionPublisher: AnyPublisher<String, Never>
    }
    
    // Coordinate
    struct CoordinateInput {
        let latitudePublisher: AnyPublisher<String, Never>
        let longitudePublisher: AnyPublisher<String, Never>
    }
    
    struct CoordinateOutput {
        let buttonStatePublisher: AnyPublisher<Bool, Never>
    }
    
    // UISwitch
    struct SwitchAndDateInput {
        let switchIsOnPublisher: AnyPublisher<Bool, Never>
        let fromDatePublisher: AnyPublisher<Date, Never>
        let toDatePublisher: AnyPublisher<Date, Never>
    }
    
    struct SwitchAndDateOutput {
        let datePickerStatePublisher: AnyPublisher<Bool, Never>
    }
    
    /// UITextField
    /// - Parameter input: Title, Description text publisher
    /// - Operation: Subscribe view's value - titleTextField.text, descriptionTextField.text
    func subscribeText(_ input: TextInput) {
        input.titlePublisher
            .sink { [weak self] titleText in
                self?.model.value.title = titleText
            }
            .store(in: &subscriptions)
        
        input.descriptionPublisher
            .sink { [weak self] descriptionText in
                self?.model.value.description = descriptionText
            }
            .store(in: &subscriptions)
    }
    
    /// Coordinate TextFIelds <-> Show Map UIButton
    /// - Parameter input: Coordinate Text Publisher
    /// - Returns: UIButton - isEnabled Publisher
    func transform(_ input: CoordinateInput) -> CoordinateOutput {
        let buttonStatePublisher = input.latitudePublisher.combineLatest(input.longitudePublisher)
            .map { [weak self] latitude, longitude in
                guard let latitude = Double(latitude),
                        let longitude = Double(longitude),
                        CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) else { return false }
                self?.model.value.coordinate.latitude = latitude
                self?.model.value.coordinate.longitude = longitude
                return CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
            .eraseToAnyPublisher()
        
        return CoordinateOutput(buttonStatePublisher: buttonStatePublisher)
    }
    
    /// UISwitch <-> UIDatePicker
    /// - Parameter input: UISwitch IsOn Publisher
    /// - Operation: Subscribe view's value - fromDatePicker.date, toDatePicker.date
    /// - Returns: UIDatePicker - isValidAtBackgroundColor(isEnabled & backgroundColor set) Publisher
    func transform(_ input: SwitchAndDateInput) -> SwitchAndDateOutput {
        let datePickerStatePublisher = input.switchIsOnPublisher
            .map { $0 ? true : false }
            .eraseToAnyPublisher()
        
        Publishers.CombineLatest3(input.switchIsOnPublisher, input.fromDatePublisher, input.toDatePublisher)
            .map { switchIsOn, fromDate, toDate in
                switchIsOn ? (fromDate, toDate) : (nil, nil)
            }
            .sink { [weak self] fromDate, toDate in
                self?.model.value.fromDate = fromDate
                self?.model.value.toDate = toDate
            }
            .store(in: &subscriptions)
            
        
        return SwitchAndDateOutput(datePickerStatePublisher: datePickerStatePublisher)
    }
}
