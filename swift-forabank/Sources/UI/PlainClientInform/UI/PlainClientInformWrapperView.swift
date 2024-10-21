//
//  PlainClientInformWrapperView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI

@available(iOS 15, *)
struct PlainClientInformWrapperView: View {
    
    private let info: ClientInformDataState
    private let config: PlainClientInformConfig
    
    public init(
        info: ClientInformDataState,
        config: PlainClientInformConfig
    ) {
        self.info = info
        self.config = config
    }

    public var body: some View {
        
        PlainClientInformView(config: config, info: info)
    }
}
