//
//  ImagePostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/22.
//

import Foundation
import UIKit

/// Storage 관련 use case
struct ImagePostsUseCase: StoragePostsUseCase {
    private let repository: ImageRepository
    
    init(repository: ImageRepository) {
        self.repository = repository
    }
    
    func upload(_ index: Int, _ image: UIImage) {
        Task { await repository.upload(at: index, image) }
    }
    
    func download(_ index: Int, completion: @escaping ((Result<UIImage, ImageLoadError>) -> Void)) {
        repository.download(index, completion)
    }
    
    func delete(_ index: Int) {
        repository.delete(index)
    }
}
