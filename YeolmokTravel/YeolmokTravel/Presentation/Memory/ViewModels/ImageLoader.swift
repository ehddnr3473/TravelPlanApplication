//
//  ImageLoader.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import Combine
import UIKit

protocol ImageLoadable: AnyObject {
    // Output
    var publisher: PassthroughSubject<UIImage, Never> { get set }
    var title: String { get }
    var index: Int { get }
    var uploadDate: String { get }
    func downloadImage()
    
    init(_ model: Memory, _ useCase: ImagePostsUseCase)
}

/// Memory를 Model로부터 가져와서 MemoriesCollectionViewCell에 데이터 제공
/// Model을 사용자 액션으로부터 업데이트하고 업로드 요청
final class ImageLoader: ImageLoadable {
    var model: Memory
    private let useCase: ImagePostsUseCase
    var publisher = PassthroughSubject<UIImage, Never>()
    
    var title: String {
        model.title
    }
    
    var index: Int {
        model.index
    }
    
    var uploadDate: String {
        DateConverter.dateToString(model.uploadDate)
    }
    
    init(_ model: Memory, _ useCase: ImagePostsUseCase) {
        self.model = model
        self.useCase = useCase
    }
    
    func downloadImage() {
        useCase.download(model.index) { result in
            switch result {
            case .success(let image):
                self.publisher.send(image)
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}
