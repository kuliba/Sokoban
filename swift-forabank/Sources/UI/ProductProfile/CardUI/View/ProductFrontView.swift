//
//  ProductFrontView.swift
//  
//
//  Created by Andryusina Nataly on 22.03.2024.
//

import SwiftUI

public struct ProductFrontView<StatusAction: View>: View {
    
    let name: String
    let headerDetails: HeaderDetails
    let footerDetails: FooterDetails
    let modifierConfig: ModifierConfig
    let config: Config
    
    let statusActionView: () -> StatusAction?
    
    public init(
        name: String,
        headerDetails: HeaderDetails,
        footerDetails: FooterDetails,
        modifierConfig: ModifierConfig,
        statusActionView: @escaping () -> StatusAction?,
        config: Config
    ) {
        self.name = name
        self.headerDetails = headerDetails
        self.footerDetails = footerDetails
        self.modifierConfig = modifierConfig
        self.statusActionView = statusActionView
        self.config = config
    }
    
    public var body: some View {
        
        FrontView(
            name: name,
            modifierConfig: modifierConfig,
            config: config,
            headerView: { HeaderView(config: config, header: headerDetails) },
            footerView: { FooterView(config: config, footer: footerDetails) },
            statusActionView: statusActionView
        )
    }
}
