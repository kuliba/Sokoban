//
//  BannersContent.swift
//  
//
//  Created by Andryusina Nataly on 09.09.2024.
//

import Foundation

public final class BannersContent<BannerPicker>: ObservableObject {
    
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

public extension BannersContent {
    
    func reload() {
        
        _reload()
    }
}
