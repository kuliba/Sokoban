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
    
    public let header: Header
    public let conditions: ListLandingComponent.Items
    public let security: ListLandingComponent.Items
    public let dropDownList: DropDownTextList
    
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
