//
//  ProductFrontView.swift
//  
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import SwiftUI

public struct ProductFrontView<ActivationView: View, StatusView: View>: View {
    
    let name: String
    let headerDetails: HeaderDetails
    let footerDetails: FooterDetails
    let modifierConfig: ModifierConfig
    let config: Config
    
    let activationView: () -> ActivationView
    let statusView: () -> StatusView

    public init(
        name: String,
        headerDetails: HeaderDetails,
        footerDetails: FooterDetails,
        modifierConfig: ModifierConfig,
        activationView: @escaping () -> ActivationView = EmptyView.init,
        statusView: @escaping () -> StatusView = EmptyView.init,
        config: Config
    ) {
        self.name = name
        self.headerDetails = headerDetails
        self.footerDetails = footerDetails
        self.modifierConfig = modifierConfig
        self.activationView = activationView
        self.statusView = statusView
        self.config = config
    }
    
    public var body: some View {
        
        FrontView(
            name: name,
            modifierConfig: modifierConfig,
            config: config,
            headerView: { HeaderView(config: config, header: headerDetails) },
            footerView: { FooterView(config: config, footer: footerDetails) },
            activationView: activationView,
            statusView: statusView
        )
    }
}
