//
//  OrderCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import HeaderLandingComponent
import ListLandingComponent
import DropDownTextListComponent

public struct OrderCardLanding {
    
    let header: Header
    let conditions: ListLandingComponent.Items
    let security: ListLandingComponent.Items
    let dropDownList: DropDownTextList
    
    public init(
        header: Header,
        conditions: ListLandingComponent.Items,
        security: ListLandingComponent.Items,
        dropDownList: DropDownTextList
    ) {
        self.header = header
        self.conditions = conditions
        self.security = security
        self.dropDownList = dropDownList
    }
}
