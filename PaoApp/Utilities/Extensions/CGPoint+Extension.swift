//
//  CGPoint+Extension.swift
//  PaoApp
//
//  Created by Saujana Shafi on 03/05/26.
//

import Foundation
import SpriteKit

//MARK: CGPoint Operator
extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }

    static func / (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }
    
    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }

    func normalized() -> CGPoint {
        return self / CGPoint(x: length(), y: length())
    }

}
