//
//  PlainClientInformBottomSheetWrapperView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI

@available(iOS 15, *)
struct PlainClientInformBottomSheetWrapperView: View {
    
    @ObservedObject var viewModel: PlainClientInformBottomSheetViewModel
    let config: PlainClientInformBottomSheetConfig
    
    public init(
        viewModel: PlainClientInformBottomSheetViewModel,
        config: PlainClientInformBottomSheetConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }

    public var body: some View {
        
        PlainClientInformBottomSheetView(
            viewModel: viewModel,
            config: config, 
            info: viewModel.info)
    }
}
