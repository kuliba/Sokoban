//
//  ClientInformListWrapperView.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI

struct ClientInformListWrapperView: View {
    
    private let info: ClientInformListDataState
    private let config: ClientInformListConfig
    
    public init(
        info: ClientInformListDataState,
        config: ClientInformListConfig
    ) {
        self.info = info
        self.config = config
    }

    public var body: some View {
        
        ClientInformListView(config: config, info: info)
    }
}
