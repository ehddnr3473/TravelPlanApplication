//
//  MemoryCellViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import Combine
import UIKit
import Domain
import FirebasePlatform

protocol MemoryCellViewModel: AnyObject {
    // Output
    var memory: YTMemory { get }
    var imagePublisher: PassthroughSubject<UIImage, Error> { get }
    var uploadDate: String { get }
    func read()
}

/// memory에 해당하는 이미지를 가져와서 MemoriesCollectionViewCell에 제공
final class DefaultMemoryCellViewModel: MemoryCellViewModel {
    private let useCaseProvider: ImagesUseCaseProvider
    // MARK: - Output
    let memory: YTMemory
    let imagePublisher = PassthroughSubject<UIImage, Error>()
    
    var uploadDate: String {
        DateConverter.dateToString(memory.uploadDate)
    }
    
    // MARK: - Init
    init(_ memory: YTMemory, _ useCaseProvider: ImagesUseCaseProvider) {
        self.memory = memory
        self.useCaseProvider = useCaseProvider
    }
    
    func read() {
        let readUseCase = useCaseProvider.provideReadImageUseCase()
        readUseCase.execute(at: memory.index) { result in
            switch result {
            case .success(let image):
                self.imagePublisher.send(image)
            case .failure(let error):
                self.imagePublisher.send(completion: .failure(error))
            }
        }
    }
}
