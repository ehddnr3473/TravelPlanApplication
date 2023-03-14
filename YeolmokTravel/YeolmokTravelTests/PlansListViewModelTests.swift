//
//  PlansListViewModelTests.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/27.
//

import XCTest
@testable import YeolmokTravel
import Domain
import CoreLocation

final class PlansListViewModelTests: XCTestCase {
    var viewModel: DefaultPlansListViewModel!
    
    override func setUp() {
        let repository = PlansRepositoryMock()
        let useCaseProvider = DefaultPlansUseCaseProvider(repository: repository)
        viewModel = DefaultPlansListViewModel(useCaseProvider)
    }
    
    // MARK: - Use Case, Repository
    func test_whenReadPlans_thenPlansContainsThreePlans() async throws {
        // when
        try await viewModel.read()
        
        // then
        XCTAssert(viewModel.plans.value.count == 3)
    }
    
    func test_whenCreatePlan_thenPlansContainsFourPlans() async throws {
        // given
        try await viewModel.read()
        let plan = Plan(title: "createdTitle", description: "createdDescription", schedules: [])
        
        // when
        try viewModel.create(plan)
        
        // then
        XCTAssert(viewModel.plans.value.count == 4)
    }
    
    func test_whenUpdatePlan_thenPlansContainsUpdatedPlan() async throws {
        // given
        try await viewModel.read()
        let index = 1
        let plan = Plan(title: "updatedTitle", description: "updatedDescription", schedules: [])
        
        // when
        try viewModel.update(at: index, plan)
        
        // then
        XCTAssert(viewModel.plans.value[index].title == "updatedTitle")
        XCTAssert(viewModel.plans.value[index].description == "updatedDescription")
    }
    
    func test_whenDeletePlan_thenPlansContainsTwoPlans() async throws {
        // given
        try await viewModel.read()
        let index = 1
        
        // when
        try await viewModel.delete(at: index)
        
        // then
        XCTAssert(viewModel.plans.value.count == 2)
        XCTAssert(viewModel.plans.value[1].title == "title2")
    }
    
    // MARK: - Get data func
    func test_getDateString_withValid_returnsExpectedString() {
        // given
        let fromDate = Date().addingTimeInterval(60*60*24*2)
        let toDate = fromDate.addingTimeInterval(60*60*24*5)
        let plan = Plan(
            title: "newPlanTitle",
            description: "newPlanDescription",
            schedules: [
                Schedule(
                    title: "newScheduleTitle",
                    description: "newScheduleDescription",
                    coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 1),
                    fromDate: fromDate,
                    toDate: toDate
                )
            ]
        )
        
        viewModel.plans.value = [plan]
        
        // when
        let dateString = viewModel.getDateString(at: 0)
        
        // then
        XCTAssert(dateString == "\(DateConverter.dateToString(fromDate)) ~ \(DateConverter.dateToString(toDate))")
    }
    
    func test_getDateString_withEmptySchedule_returnsNilDateText() {
        // given
        let plan = Plan(title: "newPlanTitle", description: "newPlanDescription", schedules: [])
        viewModel.plans.value = [plan]
        
        // when
        let dateString = viewModel.getDateString(at: 0)
        
        // then
        XCTAssert(dateString == DateConverter.Constants.nilDateText)
    }
    
    func test_getCoordinates_withValid_returnsExpectedCoordinates() {
        // given
        let coordinate1 = CLLocationCoordinate2D(latitude: 12.345, longitude: 123.456)
        let coordinate2 = CLLocationCoordinate2D(latitude: 9.8765, longitude: 98.765)
        let plan = Plan(
            title: "newPlanTitle1",
            description: "newPlanDescription1",
            schedules: [
                Schedule(
                    title: "newScheduleTitle1",
                    description: "newScheduleDescription1",
                    coordinate: coordinate1,
                    fromDate: nil,
                    toDate: nil),
                Schedule(
                    title: "newScheduleTitle2",
                    description: "newScheduleDescription2",
                    coordinate: coordinate2,
                    fromDate: nil,
                    toDate: nil)
            ]
        )
        
        viewModel.plans.value = [plan]
        
        // when
        let coordinates = viewModel.getCoordinates(at: 0)
        
        //then
        XCTAssert(coordinates[0].latitude == coordinate1.latitude)
        XCTAssert(coordinates[0].longitude == coordinate1.longitude)
        XCTAssert(coordinates[1].latitude == coordinate2.latitude)
        XCTAssert(coordinates[1].longitude == coordinate2.longitude)
    }
    
    func test_getCoordinates_withEmptySchedule_returnsEmptyArray() {
        // given
        viewModel.plans.value = [Plan(title: "newPlanTitle", description: "newPlanDescription", schedules: [])]
        
        // when
        let coordinates = viewModel.getCoordinates(at: 0)
        
        // then
        XCTAssert(coordinates.count == 0)
    }
}

// MARK: - Private. DateConvert
fileprivate extension PlansListViewModelTests {
    enum DateConverter {
        @frozen enum Constants {
            public static let nilDateText = "날짜 미지정"
        }
        
        private static let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy.MM.dd"
            return dateFormatter
        }()
        
        static func dateToString(_ date: Date?) -> String {
            if let date = date {
                return dateFormatter.string(from: date)
            } else {
                return ""
            }
        }
    }
}
