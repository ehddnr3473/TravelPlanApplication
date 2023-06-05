//
//  MemoryCellViewModelTests.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/27.
//

import XCTest
@testable import YeolmokTravel
import Combine

import Domain

final class MemoryCellViewModelTests: XCTestCase {
    
    func testRead() {
        // given
        let repository = ImagesRepositoryMock()
        let imageExpectation = expectation(description: "Image received")
        let useCaseProvider = DefaultImagesUseCaseProvider(repository: repository)
        
        let memory = Memory(id: 2, title: "title2", uploadDate: Date())
        let expectedImage = UIImage(systemName: "2.circle")!
        
        let viewModel = DefaultMemoryCellViewModel(memory, useCaseProvider)
        var cancellables = Set<AnyCancellable>()
        
        viewModel.imagePublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("imagePublisher failed with Error \(error)")
                case .finished:
                    break
                }
            }) { image in
                // then
                XCTAssertEqual(image, expectedImage)
                imageExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // when
        viewModel.read()
        
        waitForExpectations(timeout: 5)
    }
}
