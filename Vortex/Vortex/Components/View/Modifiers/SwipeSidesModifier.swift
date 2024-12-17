//
//  SwipeSidesModifier.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 19.04.2022.
//

import SwiftUI

struct SwipeSidesModifier: ViewModifier {
    
    let leftAction: () -> Void
    let rightAction: () -> Void

    func body(content: Content) -> some View {

        content
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                        .onEnded { value in

                if value.translation.width < 0 && value.translation.height > -30 && value.translation.height < 30 {

                    leftAction()

                } else if value.translation.width > 0 && value.translation.height > -30 && value.translation.height < 30 {

                    rightAction()
                }})
    }
}
