//
//  PlainClientInformBottomSheetWrapperView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI

@available(iOS 15, *)
struct PlainClientInformBottomSheetWrapperView: View {
    
    let info: ClientInformDataState
    let config: PlainClientInformBottomSheetConfig
    
    public init(
        info: ClientInformDataState,
        config: PlainClientInformBottomSheetConfig
    ) {
        self.info = info
        self.config = config
    }

    public var body: some View {
        
        PlainClientInformBottomSheetView(
            config: config,
            info: info)
    }
}
