//
//  ImageCacheManager.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import UIKit

actor ImageCacheManager {
    private var images = [UIImage]()
    
    func cachedImage(_ index: Int) -> UIImage {
        images[index]
    }
    
    func cacheImage(_ image: UIImage) {
        images.append(image)
    }
}
