//
//  PaymentsTransfersCorporateContent.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import Foundation

public final class PaymentsTransfersCorporateContent: ObservableObject {
    
    public let bannerPicker: any CorporateBannerPicker
    private let _reload: () -> Void
    
    public init(
        bannerPicker: any CorporateBannerPicker,
        reload: @escaping () -> Void
    ) {
        self.bannerPicker = bannerPicker
        self._reload = reload
    }
}

public extension PaymentsTransfersCorporateContent {
    
    func reload() {
        
        _reload()
    }
}
