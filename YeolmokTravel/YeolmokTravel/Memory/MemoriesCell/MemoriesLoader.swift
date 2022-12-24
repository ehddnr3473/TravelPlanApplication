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
class MemoriesLoader: ImageCacheService {
    private let model: Memory
    var imageCacheManager: ImageCacheManager
    let publisher = PassthroughSubject<UIImage, Never>()
    
    init(_ model: Memory, _ imageCacheManager: ImageCacheManager) {
        self.model = model
        self.imageCacheManager = imageCacheManager
    }
    
    func downloadImage() {
        // 캐시된 이미지가 있다면 캐시된 이미지 return
        
        // 없다면 send하고 캐시
//        Task { await self.imageCacher.cacheImage(image) }
    }
}
