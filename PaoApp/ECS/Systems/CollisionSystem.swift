//
//  CollisionSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

// Stores a single contact event to be processed on the next update tick.
// Using a queue avoids modifying the physics world during a contact callback.
struct CollisionEvent {
    let ballNode:  SKNode
    let otherNode: SKNode
    let isBlock:   Bool    // true = ball hit a block; false = ball hit a pickup
}

// Queues physics contacts and drains them safely on the next update cycle.
class CollisionSystem {
    private var queue: [CollisionEvent] = []

    // Called from SKPhysicsContactDelegate — appends, never processes immediately
    func enqueue(_ event: CollisionEvent) {
        queue.append(event)
    }

    // Drains the queue and returns all pending events for processing
    func dequeueAll() -> [CollisionEvent] {
        defer { queue.removeAll() }
        return queue
    }
}
