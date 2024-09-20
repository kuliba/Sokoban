//
//  PaymentsTransfersCorporateContent.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import Foundation

public final class PaymentsTransfersCorporateContent<BannerPicker>: ObservableObject {
    
    public let bannerPicker: BannerPicker
    private let _reload: () -> Void
    
    public init(
        bannerPicker: BannerPicker,
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
