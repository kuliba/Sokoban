//
//  BlockHorizontalRectangularWrappedView.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias BlockHorizontalRectangularViewModel = RxViewModel<BlockHorizontalRectangularState, BlockHorizontalRectangularEvent, BlockHorizontalRectangularEffect>

struct BlockHorizontalRectangularWrappedView: View {
    
    @ObservedObject var model: BlockHorizontalRectangularViewModel
    let factory: ViewFactory
    let config: UILanding.BlockHorizontalRectangular.Config
    
    public init(
        model: BlockHorizontalRectangularViewModel,
        factory: ViewFactory,
        config: UILanding.BlockHorizontalRectangular.Config
    ) {
        self.model = model
        self.factory = factory
        self.config = config
    }

    public var body: some View {
        
        BlockHorizontalRectangularView(
            state: model.state,
            event: model.event(_:),
            factory: factory,
            config: config)
    }
}
