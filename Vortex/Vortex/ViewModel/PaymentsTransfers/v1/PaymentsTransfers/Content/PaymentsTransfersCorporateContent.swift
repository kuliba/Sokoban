//
//  PaymentsTransfersCorporateContent.swift
//  Vortex
//
//  Created by Andryusina Nataly on 12.09.2024.
//

import PayHubUI

typealias PaymentsTransfersCorporateContent = PayHubUI.PaymentsTransfersCorporateContent

// MARK: - BannerPicker

extension BannerPickerSectionBinder: PayHubUI.CorporateBannerPicker {}

extension PayHubUI.CorporateBannerPicker {
    
    var bannerBinder: BannerPickerSectionBinder? {
        
        return self as? BannerPickerSectionBinder
    }
}

// MARK: - CorporateTransfers

struct PaymentsTransfersCorporateTransfers {
    
    let meToMe: MeToMeDomain.Flow
    let openProduct: OpenProductDomain.Flow
}

extension PaymentsTransfersCorporateTransfers: CorporateTransfersProtocol {}

extension CorporateTransfersProtocol {
    
    var corporateTransfers: PaymentsTransfersCorporateTransfers? {
        
        return self as? PaymentsTransfersCorporateTransfers
    }
}
