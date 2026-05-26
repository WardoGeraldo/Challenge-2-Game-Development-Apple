//
//  CollisionSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import SpriteKit

// A single contact event queued from SKPhysicsContactDelegate for safe processing.
struct CollisionEvent {
    let ballNode:  SKNode
    let otherNode: SKNode
    let isBlock:   Bool    // true = hit a block; false = hit a pickup
}

// Queues physics contacts and drains them on the next update tick.
// Never process contacts directly inside didBegin — the physics world is locked then.
class CollisionSystem {
    private var queue: [CollisionEvent] = []

    func enqueue(_ event: CollisionEvent) {
        queue.append(event)
    }

    func dequeueAll() -> [CollisionEvent] {
        defer { queue.removeAll() }
        return queue
    }
}
