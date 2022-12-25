//
//  MemoriesLoader.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import Combine
import UIKit

/// Memory를 Model로부터 가져와서 MemoriesCollectionViewCell에 데이터 제공
/// Model을 사용자 액션으로부터 업데이트하고 업로드 요청
class MemoriesLoader {
    private let model: Memory
    let imageLoader: ImageLoader
    let publisher = PassthroughSubject<UIImage, Never>()
    
    init(_ model: Memory, _ imageLoader: ImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var title: String {
        model.title
    }
    
    var index: Int {
        model.index
    }
    
    var uploadDate: String {
        DateConverter.dateToString(model.uploadDate)
    }
    
    func uploadImage(_ index: Int, image: UIImage) {
        Task { uploadImage(index, image: image) }
    }
    
    func downloadImage() {
        imageLoader.download(model.index) { image in
            if let image = image {
                self.publisher.send(image)
            }
        }
    }
}
