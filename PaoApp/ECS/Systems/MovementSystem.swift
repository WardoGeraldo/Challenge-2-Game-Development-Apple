//
//  MovementSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// TODO: [ECS Team] Implement MovementSystem.
//
// MovementSystem handles two things:
//
// 1. Rover movement (blocks that slide horizontally back and forth):
//    Called every frame from GameScene.update().
//    Loop over all entities that have a RoverComponent and move them
//    left/right by velocity * deltaTime. Reverse direction when they
//    hit the grid edge (gridOriginX or gridOriginX + gridWidth).
//
//    Required method:
//    func update(deltaTime: CGFloat, entityManager: EntityManager,
//                cell: CGFloat, gap: CGFloat,
//                gridOriginX: CGFloat, gridWidth: CGFloat)
//
// 2. Unstick rovers after a nearby block is destroyed:
//    func unstickRovers(near position: CGPoint, entityManager: EntityManager, cell: CGFloat)
//    Rovers trapped between destroyed blocks can get stuck. Call this after any block dies.
//
// Reference: ECS_Prototype → MovementSystem.swift (full implementation available there)

class MovementSystem: GKComponentSystem<GKComponent> {

}
