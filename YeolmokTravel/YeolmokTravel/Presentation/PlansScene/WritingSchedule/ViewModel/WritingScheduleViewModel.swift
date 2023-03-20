//
//  WritingScheduleViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/03.
//

import Foundation
import Combine
import CoreLocation
import Domain
import FirebasePlatform

enum ScheduleError: String, Error {
    case titleError = "제목을 입력해주세요."
    case preToDateError = "시작 날짜가 종료 날짜 이후입니다."
    case fromDateError = "From 날짜를 선택해주세요."
    case toDateError = "To 날짜를 선택해주세요."
    case coordinateError = "유효하지 않은 좌표입니다."
}

protocol WritingSchduleViewModelInput {
    func editingChangedCoordinateTextField(_ latitude: String, _ longitude: String) -> Bool
    func toggledSwitch(_ isOn: Bool, _ fromDate: Date, _ toDate: Date)
    func didTouchUpCancelButton()
    func perfomeCoordinateSearch(with query: String) async throws -> (latitude: String, longitude: String)
}

protocol WritingScheduleViewModelOutPut {
    var title: CurrentValueSubject<String, Never> { get }
    var description: CurrentValueSubject<String, Never> { get }
    var fromDate: CurrentValueSubject<Date?, Never> { get }
    var toDate: CurrentValueSubject<Date?, Never> { get }
    var coordinate: CurrentValueSubject<CLLocationCoordinate2D, Never> { get }
    var isChanged: Bool { get }
    func validate(_ latitude: String, _ longitude: String) throws
    func getSchedule() -> Schedule
}

protocol WritingScheduleViewModel: WritingSchduleViewModelInput, WritingScheduleViewModelOutPut, AnyObject {}

final class DefaultWritingScheduleViewModel: WritingScheduleViewModel {
    private let useCaseProvider: CoordinateUseCaseProvider
    private var scheduleTracker: ScheduleTracker
    // MARK: - Output
    let title: CurrentValueSubject<String, Never>
    let description: CurrentValueSubject<String, Never>
    let fromDate: CurrentValueSubject<Date?, Never>
    let toDate: CurrentValueSubject<Date?, Never>
    let coordinate: CurrentValueSubject<CLLocationCoordinate2D, Never>
    var isChanged: Bool { scheduleTracker.isChanged }
    
    // MARK: - Init
    init(schedule: Schedule, useCaseProvider: CoordinateUseCaseProvider) {
        self.useCaseProvider = useCaseProvider
        self.title = CurrentValueSubject<String, Never>(schedule.title)
        self.description = CurrentValueSubject<String, Never>(schedule.description)
        self.fromDate = CurrentValueSubject<Date?, Never>(schedule.fromDate)
        self.toDate = CurrentValueSubject<Date?, Never>(schedule.toDate)
        self.coordinate = CurrentValueSubject<CLLocationCoordinate2D, Never>(schedule.coordinate)
        self.scheduleTracker = ScheduleTracker(schedule)
    }
    
    func validate(_ latitude: String, _ longitude: String) throws {
        if title.value == "" {
            throw ScheduleError.titleError
        } else if !isPreFromDate {
            throw ScheduleError.preToDateError
        } else if fromDate.value == nil && toDate.value != nil {
            throw ScheduleError.fromDateError
        } else if fromDate.value != nil && toDate.value == nil {
            throw ScheduleError.toDateError
        } else if !validateCoordinate(latitude, longitude) {
            throw ScheduleError.coordinateError
        }
    }
    
    func getSchedule() -> Schedule {
        Schedule(title: title.value,
                 description: description.value,
                 coordinate: coordinate.value,
                 fromDate: fromDate.value,
                 toDate: toDate.value)
    }
}

// MARK: - Input. View event methods
extension DefaultWritingScheduleViewModel {
    func editingChangedCoordinateTextField(_ latitude: String, _ longitude: String) -> Bool {
        guard validateCoordinate(latitude, longitude) else { return false }
        guard let latitude = CLLocationDegrees(latitude), let longitude = CLLocationDegrees(longitude) else { return false }
        coordinate.value.latitude = latitude
        coordinate.value.longitude = longitude
        return true
    }
    
    func toggledSwitch(_ isOn: Bool, _ fromDate: Date, _ toDate: Date) {
        if isOn {
            self.fromDate.value = fromDate
            self.toDate.value = toDate
        } else {
            self.fromDate.value = nil
            self.toDate.value = nil
        }
    }
    
    func didTouchUpCancelButton() {
        scheduleTracker.schedule = Schedule(title: title.value,
                                            description: description.value,
                                            coordinate: coordinate.value,
                                            fromDate: fromDate.value,
                                            toDate: toDate.value)
    }
    
    func perfomeCoordinateSearch(with query: String) async throws -> (latitude: String, longitude: String) {
        let useCase = useCaseProvider.provideSearchCoordinateUseCase()
        let coordinate = try await useCase.execute(query: .init(query: query))
        self.coordinate.value.latitude = coordinate.latitude
        self.coordinate.value.longitude = coordinate.longitude
        return (String(coordinate.latitude), String(coordinate.longitude))
    }
}

// MARK: - Private
private extension DefaultWritingScheduleViewModel {
    var isPreFromDate: Bool {
        guard let toDate = toDate.value,
              let fromDate = fromDate.value,
              let slicedFromDate = DateConverter.stringToDate(DateConverter.dateToString(fromDate)),
              let slicedToDate = DateConverter.stringToDate(DateConverter.dateToString(toDate)) else { return true }
        return slicedFromDate <= slicedToDate
    }
    
    func validateCoordinate(_ latitude: String, _ longitude: String) -> Bool {
        guard let latitude = Double(latitude) else { return false }
        guard let longitude = Double(longitude) else { return false }
        guard CLLocationCoordinate2DIsValid(
            CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
        ) else { return false }
        return true
    }
}
