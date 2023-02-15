//
//  ConcreteTravelPlanReadUseCaseTests.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/15.
//

import XCTest
@testable import YeolmokTravel

final class ConcreteTravelPlanReadUseCaseTests: XCTestCase {
    var mockTravelPlanRepository: MockTravelPlanRepository!
    var readUseCase: ConcreteTravelPlanReadUseCase!

    override func setUp() {
        super.setUp()
        mockTravelPlanRepository = MockTravelPlanRepository()
        readUseCase = ConcreteTravelPlanReadUseCase(mockTravelPlanRepository)
    }
    
    override func tearDown() {
        mockTravelPlanRepository = nil
        readUseCase = nil
        super.tearDown()
    }
    
    func test_execute() async throws {
        // Given
        let expectedTravelPlans = [
            TravelPlan(title: "Title 1", description: "Description 1", schedules: []),
            TravelPlan(title: "Title 2", description: "Description 2", schedules: [])
        ]
        mockTravelPlanRepository.readStub = { () async throws -> [TravelPlan] in
            return expectedTravelPlans
        }
        
        // When
        let result = try await readUseCase.execute()
        
        // Then
        XCTAssertEqual(result, expectedTravelPlans)
        XCTAssertTrue(mockTravelPlanRepository.readCalled)
    }
}

final class MockTravelPlanRepository: AbstractTravelPlanRepository {
    var uploadCalled = false
    var readCalled = false
    var deleteCalled = false
    var readStub: (() async throws -> [TravelPlan])?
    
    func upload(at index: Int, travelPlanDTO: TravelPlanDTO) async throws {
        uploadCalled = true
    }
    
    func read() async throws -> [TravelPlan] {
        readCalled = true
        return try await readStub?() ?? []
    }
    
    func delete(at index: Int) async throws {
        deleteCalled = true
    }
}


