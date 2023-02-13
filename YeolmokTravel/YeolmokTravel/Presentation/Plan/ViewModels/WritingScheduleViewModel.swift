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
    associatedtype CoordinateInput
    associatedtype CoordinateOutput
    associatedtype SwitchAndDateInput
    associatedtype SwitchAndDateOutput
    
    func transform(_ input: CoordinateInput) -> CoordinateOutput
    func transform(_ input: SwitchAndDateInput) -> SwitchAndDateOutput
    
    // Input
    func setScheduleTracker(_ title: String, _ description: String) // scheduleTracker.schedule set
    func deallocate() // Deallocate initial string value
    
    
    // Output
    func isValidSave(_ title: String, _ description: String) throws
}

final class ConcreteWritingScheduleViewModel: WritingScheduleViewModel {
    private(set) var scheduleTracker: ScheduleTracker
    
    private(set) var initialTitleText: String?
    private(set) var initialDescriptionText: String?
    private(set) var coordinate: CLLocationCoordinate2D
    private(set) var fromDate: Date?
    private(set) var toDate: Date?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var verifyPreFromDate: Bool {
        guard let toDate = toDate,
                let fromDate = fromDate,
                let slicedFromDate = DateConverter.stringToDate(DateConverter.dateToString(fromDate)),
                let slicedToDate = DateConverter.stringToDate(DateConverter.dateToString(toDate)) else { return true }
        return slicedFromDate <= slicedToDate
    }
    
    init(_ model: Schedule) {
        self.scheduleTracker = ScheduleTracker(model)
        self.initialTitleText = model.title
        self.initialDescriptionText = model.description
        self.coordinate = model.coordinate
    }
    
    deinit {
        print("deinit: WritingScheduleViewModel")
    }
    
    func setScheduleTracker(_ title: String, _ description: String) {
        scheduleTracker.schedule = Schedule(title: title,
                                            description: description,
                                            coordinate: coordinate,
                                            fromDate: fromDate,
                                            toDate: toDate)
    }
    
    func isValidSave(_ title: String, _ description: String) throws {
        if title == "" {
            throw ScheduleError.titleError
        } else if !verifyPreFromDate {
            throw ScheduleError.preToDateError
        } else if fromDate == nil && toDate != nil {
            throw ScheduleError.fromDateError
        } else if fromDate != nil && toDate == nil {
            throw ScheduleError.toDateError
        }
    }
    
    func deallocate() {
        initialTitleText = nil
        initialDescriptionText = nil
    }
}

extension ConcreteWritingScheduleViewModel {
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
                self?.fromDate = fromDate
                self?.toDate = toDate
            }
            .store(in: &subscriptions)
            
        
        return SwitchAndDateOutput(datePickerStatePublisher: datePickerStatePublisher)
    }
}
