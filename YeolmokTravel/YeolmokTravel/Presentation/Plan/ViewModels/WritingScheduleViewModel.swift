//
//  WritingScheduleViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import Foundation
import Combine
import CoreLocation

enum ScheduleError: Error {
    case titleError
    case preToDateError
    case fromDateError
    case toDateError
    case coordinateError
}

private protocol WritingScheduleViewModelType: AnyObject {
    associatedtype TextInput
    associatedtype CoordinateInput
    associatedtype CoordinateOutput
    associatedtype SwitchInput
    associatedtype SwitchOutput
    associatedtype DateInput
    
    func subscribeText(_ input: TextInput)
    func transform(_ input: CoordinateInput) -> CoordinateOutput
    func transform(_ input: SwitchInput) -> SwitchOutput
    func subscribeDate(_ input: DateInput)
}

final class WritingScheduleViewModel {
    private(set) var scheduleTracker: ScheduleTracker
    private(set) var model: Schedule
    
    private(set) var title: String
    private var description: String
    private var fromDate: Date?
    private var toDate: Date?
    private(set) var coordinate: CLLocationCoordinate2D
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var verifyPreFromDate: Bool {
        guard let toDate = toDate,
                let fromDate = fromDate,
                let slicedFromDate = DateConverter.stringToDate(DateConverter.dateToString(fromDate)),
                let slicedToDate = DateConverter.stringToDate(DateConverter.dateToString(toDate)) else { return true }
        return slicedFromDate <= slicedToDate
    }
    
    init(_ model: Schedule) {
        self.model = model
        self.scheduleTracker = ScheduleTracker(model)
        self.title = model.title
        self.description = model.description
        self.fromDate = model.fromDate
        self.toDate = model.toDate
        self.coordinate = model.coordinate
    }
    
    deinit {
        print("deinit: WritingScheduleViewModel")
    }
    
    func setSchedule() throws {
        if title == "" {
            throw ScheduleError.titleError
        } else if !verifyPreFromDate {
            throw ScheduleError.preToDateError
        } else if fromDate == nil && toDate != nil {
            throw ScheduleError.fromDateError
        } else if fromDate != nil && toDate == nil {
            throw ScheduleError.toDateError
        } else if coordinate.latitude == 0 && coordinate.longitude == 0 {
            throw ScheduleError.coordinateError
        } else {
            model.setSchedule(title, description, coordinate, fromDate, toDate)
        }
    }
    
    func setPlan() {
        scheduleTracker.setPlan(Schedule(title: title,
                                     description: description,
                                     coordinate: coordinate,
                                     fromDate: fromDate,
                                     toDate: toDate))
    }
}

extension WritingScheduleViewModel: WritingScheduleViewModelType {
    // Title UITextField
    struct TextInput {
        let titlePublisher: AnyPublisher<String, Never>
        let descriptionPublisher: PassthroughSubject<String, Never>
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
    struct SwitchInput {
        let switchIsOnPublisher: AnyPublisher<Bool, Never>
        let initialFromDate: Date
        let initialToDate: Date
    }
    
    struct SwitchOutput {
        let datePickerStatePublisher: AnyPublisher<Bool, Never>
    }
    
    // UIDatePicker
    struct DateInput {
        let fromDatePublisher: AnyPublisher<Date, Never>
        let toDatePublisher: AnyPublisher<Date, Never>
    }
    
    struct DateOutput {
        let isVaildDatePublisher: AnyPublisher<Bool, Never>
    }
    
    /// UITextField
    /// - Parameter input: Title, Description text publisher
    /// - Operation: Subscribe view's value - titleTextField.text, descriptionTextField.text
    func subscribeText(_ input: TextInput) {
        input.titlePublisher
            .sink { [weak self] titleText in
                self?.title = titleText
            }
            .store(in: &subscriptions)
        
        input.descriptionPublisher
            .sink { [weak self] descriptionText in
                self?.description = descriptionText
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
                self?.coordinate.latitude = latitude
                self?.coordinate.longitude = longitude
                return CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
            .eraseToAnyPublisher()
        
        return CoordinateOutput(buttonStatePublisher: buttonStatePublisher)
    }
    
    /// UISwitch <-> UIDatePicker
    /// - Parameter input: UISwitch IsOn Publisher
    /// - Returns: UIDatePicker - isEnabled, UIDatePicker - backgroundColor Publisher
    func transform(_ input: SwitchInput) -> SwitchOutput {
        let datePickerStatePublisher = input.switchIsOnPublisher
            .map { [weak self] in
                if $0 {
                    self?.fromDate = input.initialFromDate
                    self?.toDate = input.initialToDate
                    return true
                } else {
                    self?.fromDate = nil
                    self?.toDate = nil
                    return false
                }
            }
            .eraseToAnyPublisher()
        
        return SwitchOutput(datePickerStatePublisher: datePickerStatePublisher)
    }
    
    /// UIDatePicker
    /// - Parameter input: UIDatePicker Date Publisher
    /// - Operation: Subscribe view's value - fromDatePicker.date, toDatePicker.date
    func subscribeDate(_ input: DateInput) {
        input.fromDatePublisher
            .sink { [weak self] fromDate in
                self?.fromDate = fromDate
            }
            .store(in: &subscriptions)
        
        input.toDatePublisher
            .sink { [weak self] toDate in
                self?.toDate = toDate
            }
            .store(in: &subscriptions)
    }
}
