//
//  GameView.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            GeometryReader { proxy in
                let base =
                    proxy.size.width < proxy.size.height
                    ? proxy.size.width - 16 : proxy.size.height - 16
                let cellWidth: CGFloat =
                    proxy.size.width < proxy.size.height
                    ? (base
                        - base.truncatingRemainder(dividingBy: 7))
                        / 7
                    : (base
                        - base.truncatingRemainder(dividingBy: 7))
                        / 9
                let width: CGFloat = cellWidth * 7
                let height: CGFloat = cellWidth * 9

                SpriteView(
                    scene: GameScene(
                        size: CGSize(
                            width: width,
                            height: height,
                        )
                    )
                )
                .ignoresSafeArea()
                .frame(
                    width: width,
                    height: height,
                    //                    alignment: .center,
                )
                .padding(8)
            }

            Spacer()
        }
    }
}

#Preview {
    GameView()
}
