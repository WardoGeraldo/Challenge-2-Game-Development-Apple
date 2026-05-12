//
//  PhysicsCategory.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation

public enum PhysicsCategory {
    static let ball:   UInt32 = 0x1 << 0   // 1
    static let block:  UInt32 = 0x1 << 1   // 2
    static let wall:   UInt32 = 0x1 << 2   // 4
    static let player: UInt32 = 0x1 << 3   // 8
    static let pickup: UInt32 = 0x1 << 4   // 16
}
