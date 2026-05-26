//
//  GameScenePart2.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit
extension GameScene {

    // MARK: - Grid Layout
    // Derives cell size, grid origin, and shooter position from the screen frame.
//    func computeLayout(in view: SKView) {
//        
//        gridW = frame.width * 0.94
//        cell = gridW / CGFloat(GameConstants.cols)
//        
//        gridH = cell * CGFloat(GameConstants.blockRows + 1)
//        
//        // sementara center dulu
//        let gridX = frame.midX - gridW / 2
//        let gridY = frame.midY - gridH / 2 - 50
//        
//        gridOrigin = CGPoint(
//            x: gridX,
//            y: gridY
//        )
//        
//        shootX = frame.midX
//        
//        // posisi shooter
//        shootY = cellCenter(
//            col: 0,
//            row: GameConstants.blockRows
//        ).y
//    }
    
    func computeLayout(in view: SKView) {

        // ukuran grid mengikuti bgCheckeredNode
        gridW = frame.width * 0.94 * gridScale

        // cell otomatis ikut mengecil
        cell = gridW / CGFloat(GameConstants.cols)

        // tinggi grid mengikuti jumlah row
        gridH = cell * CGFloat(GameConstants.blockRows + 1)

        // posisi grid tetap center
        let gridX = frame.midX - gridW / 2
        let gridY = frame.midY - gridH / 2 - 20

        gridOrigin = CGPoint(
            x: gridX,
            y: gridY
        )

        shootX = frame.midX

        shootY = cellCenter(
            col: 0,
            row: GameConstants.blockRows
        ).y
    }
    
    func cellCenter(col: Int, row: Int) -> CGPoint {
        
        return CGPoint(
            x:
                gridOrigin.x
            + CGFloat(col) * cell
            + cell / 2,
            
            y:
                gridOrigin.y
            + gridH
            - CGFloat(row) * cell
            - cell / 2
        )
    }
    
    func clampToPlayArea(_ point: CGPoint) -> CGPoint {
        
        let minX = gridOrigin.x + playAreaInset
        let maxX = gridOrigin.x + gridW - playAreaInset
        let minY = gridOrigin.y + playAreaInset
        let maxY = gridOrigin.y + gridH - playAreaInset
        
        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }

    

}
