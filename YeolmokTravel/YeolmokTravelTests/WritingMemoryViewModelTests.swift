//
//  WritingMemoryViewModelTests.swift
//  YeolmokTravelTests
//
//  Created by 김동욱 on 2023/02/27.
//

import XCTest
@testable import YeolmokTravel
import Domain

final class WritingMemoryViewModelTests: XCTestCase {
    
    func test_whenUploadMemoryAndImage_thenContainsExpectedMemoryAndExpectedImage() async throws {
        // given
        let memoriesRepository = MemoriesRepositoryMock()
        let imagesRepository = ImagesRepositoryMock()
        
        let memoriesUseCaseProvider = DefaultMemoriesUseCaseProvider(repository: memoriesRepository)
        let imagesUseCaseProvider = DefaultImagesUseCaseProvider(repository: imagesRepository)
        
        let viewModel = DefaultWritingMemoryViewModel(memoriesUseCaseProvider: memoriesUseCaseProvider,
                                                  imagesUseCaseProvider: imagesUseCaseProvider)
        
        let expectedImage = UIImage(systemName: "testtube.2")!
        let memory = Memory(id: 3, title: "newMemoryTitle", uploadDate: Date())
        
        // when
        try await viewModel.upload(memory, expectedImage)
        
        // then
        XCTAssertEqual(memoriesRepository.memories[memory.id].title, memory.title)
        XCTAssertEqual(imagesRepository.images[memory.id], expectedImage)
    }
}
