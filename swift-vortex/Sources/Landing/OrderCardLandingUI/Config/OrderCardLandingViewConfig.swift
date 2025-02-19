//
//  OrderCardLandingViewConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.12.2024.
//

import Foundation
import DropDownTextListComponent

public struct OrderCardLandingViewConfig {

    let dropDownConfig: DropDownTextListConfig
    let headerConfig: HeaderViewConfig
    
    public init(
        dropDownConfig: DropDownTextListConfig,
        headerConfig: HeaderViewConfig
    ) {
        self.dropDownConfig = dropDownConfig
        self.headerConfig = headerConfig
    }
}
