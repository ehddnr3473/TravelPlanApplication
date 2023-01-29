//
//  StorageRepository.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation
import UIKit

protocol StorageRepository: AnyObject {
    func cachedImage(_ index: Int) -> UIImage?
    func cacheImage(_ index: Int, image: UIImage)
    func upload(at index: Int, _ image: UIImage) async
    func download(_ index: Int, _ completion: @escaping ((Result<UIImage, ImageLoadError>) -> Void))
    func delete(_ index: Int)
}
