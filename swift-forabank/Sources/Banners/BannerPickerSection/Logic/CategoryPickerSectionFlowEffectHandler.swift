//
//  BannerPickerSectionFlowEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

public final class BannerPickerSectionFlowEffectHandler<Banner, SelectedBanner, BannerList> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = BannerPickerSectionFlowEffectHandlerMicroServices<Banner, SelectedBanner, BannerList>
}

public extension BannerPickerSectionFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .showAll(banners):
            microServices.showAll(banners) { dispatch(.receive(.list($0))) }
            
        case let .showBanner(banner):
            microServices.showBanner(banner) { dispatch(.receive(.banner($0))) }
        }
    }
}

public extension BannerPickerSectionFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = BannerPickerSectionFlowEvent<Banner, SelectedBanner, BannerList>
    typealias Effect = BannerPickerSectionFlowEffect<Banner>
}
