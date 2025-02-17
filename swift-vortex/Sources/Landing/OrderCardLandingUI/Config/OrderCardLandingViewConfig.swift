//
//  OrderCardLandingViewConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import Foundation

public struct OrderCardLandingViewConfig {

    let headerConfig: HeaderViewConfig
    let orderCardHorizontalConfig: OrderCardHorizontalConfig
    let orderCardVerticalConfig: OrderCardVerticalListConfig
    let dropDownListConfig: DropDownListConfig
    
    public init(
        headerConfig: HeaderViewConfig,
        orderCardHorizontalConfig: OrderCardHorizontalConfig,
        orderCardVerticalConfig: OrderCardVerticalListConfig,
        dropDownListConfig: DropDownListConfig
    ) {
        self.headerConfig = headerConfig
        self.orderCardHorizontalConfig = orderCardHorizontalConfig
        self.orderCardVerticalConfig = orderCardVerticalConfig
        self.dropDownListConfig = dropDownListConfig
    }
}
