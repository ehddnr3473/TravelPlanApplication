//
//  MemoryImageReadUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/02/11.
//

import Foundation
import UIKit

protocol MemoryImageReadUseCase {
    func execute(at index: Int, completion: @escaping ((Result<UIImage, MemoryImageRepositoryError>) -> Void))
}

struct ConcreteMemoryImageReadUseCase: MemoryImageReadUseCase {
    private let memoryImageRepository: AbstractMemoryImageRepository
    
    init(_ memoryImageRepository: AbstractMemoryImageRepository) {
        self.memoryImageRepository = memoryImageRepository
    }
    
    func execute(at index: Int, completion: @escaping ((Result<UIImage, MemoryImageRepositoryError>) -> Void)) {
        memoryImageRepository.read(index, completion)
    }
}
