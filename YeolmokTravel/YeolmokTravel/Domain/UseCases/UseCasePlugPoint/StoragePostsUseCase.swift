//
//  StoragePostsUseCase.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2023/01/27.
//

import Foundation
import UIKit

protocol StoragePostsUseCase {
    func upload(_ index: Int, _ image: UIImage)
    func download(_ index: Int, completion: @escaping ((Result<UIImage, ImageLoadError>) -> Void))
    func delete(_ index: Int)
}
