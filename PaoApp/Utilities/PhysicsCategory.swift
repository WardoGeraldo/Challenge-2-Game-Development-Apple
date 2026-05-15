//
//  PhysicsCategory.swift
//  challenge2test
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation

public enum PhysicsCategory {
    static let none: UInt32 = 0x1 << 0
    static let ball: UInt32 = 0x1 << 1
    static let block: UInt32 = 0x1 << 2
    static let item: UInt32 = 0x1 << 3
    static let wall: UInt32 = 0x1 << 4
}
