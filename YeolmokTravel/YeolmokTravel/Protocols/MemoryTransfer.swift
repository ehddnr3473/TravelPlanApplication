//
//  MemoryTransfer.swift
//  YeolmokTravel
//
//  Created by 김동욱 on 2022/12/24.
//

import Foundation
import UIKit

protocol MemoryTransfer {
    func memoryHandler(_ image: UIImage, _ memory: Memory) async
}
