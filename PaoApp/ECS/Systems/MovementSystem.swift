//
//  MovementSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import CoreGraphics



// MARK: - MovementSystem

// Updates rover block positions each frame.
// Reverses direction on wall/block collision; wedges when blocked on both sides.
class MovementSystem {

    // Called from GameScene.update() every frame
    func update(
        deltaTime: CGFloat,
        entityManager: EntityManager,
        cell: CGFloat,
        gap: CGFloat,
        gridOriginX: CGFloat,
        gridWidth: CGFloat
    ) {
        let step       = cell + gap
        let leftBound  = gridOriginX + gap + cell / 2
        let rightBound = gridOriginX + gridWidth - gap - cell / 2
        let tolerance  = cell * 0.55   // Y-distance threshold for "same row"

        for entity in entityManager.entities(with: RoverComponent.self) {
            guard let rover  = entity.component(ofType: RoverComponent.self),
                  let render = entity.component(ofType: RenderComponent.self),
                  !rover.isStuck else { continue }

            let node = render.node
            let newX = node.position.x + CGFloat(rover.direction) * GameConstants.roverSpeed * deltaTime

            let sideBlocked = hasBlockAdjacent(to: node, inDirection: rover.direction,
                                               tolerance: tolerance, step: step,
                                               entityManager: entityManager)
            let hitWall = (rover.direction ==  1 && newX >= rightBound)
                       || (rover.direction == -1 && newX <= leftBound)

            if hitWall || sideBlocked {
                let rev        = -rover.direction
                let revBlocked = hasBlockAdjacent(to: node, inDirection: rev,
                                                  tolerance: tolerance, step: step,
                                                  entityManager: entityManager)
                let revHitWall = (rev ==  1 && node.position.x >= rightBound - cell * 0.5)
                              || (rev == -1 && node.position.x <= leftBound  + cell * 0.5)

                if revBlocked || revHitWall {
                    rover.isStuck = true
                } else {
                    rover.direction = rev
                    node.position.x += CGFloat(rover.direction) * GameConstants.roverSpeed * deltaTime
                }
            } else {
                node.position.x = newX
            }
        }
    }

    // Unstick any rover within 1.8 cells of a destroyed block
    func unstickRovers(near pos: CGPoint, entityManager: EntityManager, cell: CGFloat) {
        for entity in entityManager.entities(with: RoverComponent.self) {
            guard let rover  = entity.component(ofType: RoverComponent.self),
                  let render = entity.component(ofType: RenderComponent.self),
                  rover.isStuck else { continue }

            let dist = hypot(render.node.position.x - pos.x,
                             render.node.position.y - pos.y)
            if dist < cell * 1.8 {
                rover.isStuck   = false
                rover.direction = pos.x > render.node.position.x ? -1 : 1
            }
        }
    }

    // Returns true if another block exists adjacent in the given direction on the same row
    private func hasBlockAdjacent(
        to node: SKNode,
        inDirection dir: Int,
        tolerance: CGFloat,
        step: CGFloat,
        entityManager: EntityManager
    ) -> Bool {
        for other in entityManager.entities(with: BlockTypeComponent.self) {
            guard let otherRender = other.component(ofType: RenderComponent.self),
                  otherRender.node !== node else { continue }

            let dx      = otherRender.node.position.x - node.position.x
            let dy      = abs(otherRender.node.position.y - node.position.y)
            let sideDir = dx > 0 ? 1 : -1
            if dy < tolerance && abs(dx) < step * 1.4 && sideDir == dir { return true }
        }
        return false
    }
}
