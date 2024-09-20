//
//  BannerPickerSectionFlowEffectHandlerMicroServices.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

public struct BannerPickerSectionFlowEffectHandlerMicroServices<Banner, SelectedBanner, BannerList> {
    
    public let showAll: ShowAll
    public let showBanner: ShowBanner
    
    public init(
        showAll: @escaping ShowAll,
        showBanner: @escaping ShowBanner
    ) {
        self.showAll = showAll
        self.showBanner = showBanner
    }
}

public extension BannerPickerSectionFlowEffectHandlerMicroServices {
    
    typealias ShowAll = ([Banner], @escaping (BannerList) -> Void) -> Void
    typealias ShowBanner = (Banner, @escaping (SelectedBanner) -> Void) -> Void
}
