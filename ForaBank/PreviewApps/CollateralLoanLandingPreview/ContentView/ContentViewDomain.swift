//
//  ContentViewDomain.swift
//  CollateralLoanLandingPreview
//
//  Created by Valentin Ozerov on 06.11.2024.
//

import Foundation
import PayHubUI
import CollateralLoanLandingShowCaseUI

typealias ContentViewDomain = PayHubUI.FlowDomain<ContentViewSelect, ContentViewNavigation>

enum ContentViewSelect {
    
    case showcase
}

enum ContentViewNavigation {
    
    case showcase(CollaterlLoanPicker)
}

typealias CollaterlLoanPicker = LoadablePickerModel<UUID, CollateralLoadProduct>
typealias CollateralLoadProduct = CollateralLoanLandingShowCaseData.Product
