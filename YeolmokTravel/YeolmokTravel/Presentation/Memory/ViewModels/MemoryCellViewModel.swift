//
//  ConcreteMemoryCellViewModel.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import Combine
import UIKit
import Domain
import FirebasePlatform

private protocol MemoryCellViewModel: AnyObject {
    // Output
    var model: YTMemory { get }
    var uploadDate: String { get }
    func read()
    
    init(_ model: YTMemory, _ useCaseProvider: MemoryImageUseCaseProvider)
}

/// model(Memory)에 해당하는 이미지를 가져와서 MemoriesCollectionViewCell에 데이터 제공
final class ConcreteMemoryCellViewModel: MemoryCellViewModel {
    let model: YTMemory
    private let useCaseProvider: MemoryImageUseCaseProvider
    let imagePublisher = PassthroughSubject<UIImage, Error>()
    
    var uploadDate: String {
        DateConverter.dateToString(model.uploadDate)
    }
    
    init(_ model: YTMemory, _ useCaseProvider: MemoryImageUseCaseProvider) {
        self.model = model
        self.useCaseProvider = useCaseProvider
    }
    
    func read() {
        let readUseCase = useCaseProvider.provideMemoryImageReadUseCase()
        readUseCase.execute(at: model.index) { result in
            switch result {
            case .success(let image):
                self.imagePublisher.send(image)
            case .failure(let error):
                self.imagePublisher.send(completion: .failure(error))
            }
        }
    }
}
