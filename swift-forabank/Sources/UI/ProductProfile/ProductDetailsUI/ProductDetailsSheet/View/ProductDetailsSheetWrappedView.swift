//
//  ProductDetailsSheetWrappedView.swift
//  
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import RxViewModel
import SwiftUI
import Tagged

public typealias ProductDetailsSheetViewModel = RxViewModel<ProductDetailsSheetState, ProductDetailsSheetEvent, ProductDetailsSheetEffect>

public struct ProductDetailsSheetWrappedView: View {
    
    @ObservedObject private var viewModel: ProductDetailsSheetViewModel
    let config: SheetConfig
    
    public init(
        viewModel: ProductDetailsSheetViewModel,
        config: SheetConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }

    public var body: some View {
        
        ProductDetailsSheet(
            buttons: viewModel.state.buttons,
            event: { viewModel.event(.buttonTapped($0)) },
            config: config
        )
    }
}
