//
//  PaymentsTransfersCorporateContent.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import Foundation

public final class PaymentsTransfersCorporateContent: ObservableObject {
    
    public let bannerPicker: any CorporateBannerPicker
    public let corporateTransfers: any CorporateTransfersProtocol
    private let _reload: () -> Void
    
    public init(
        bannerPicker: any CorporateBannerPicker,
        corporateTransfers: any CorporateTransfersProtocol,
        reload: @escaping () -> Void
    ) {
        self.bannerPicker = bannerPicker
        self.corporateTransfers = corporateTransfers
        self._reload = reload
    }
}

public extension PaymentsTransfersCorporateContent {
    
    func reload() {
        
        _reload()
    }
}
