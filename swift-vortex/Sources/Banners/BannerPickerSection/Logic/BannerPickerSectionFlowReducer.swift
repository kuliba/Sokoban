//
//  BannerPickerSectionFlowReducer.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

public final class BannerPickerSectionFlowReducer<Banner, SelectedBanner, BannerList> {
    
    public init() {}
}

public extension BannerPickerSectionFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        
        switch event {
        case .dismiss:
            state.destination = nil
            
        case let .receive(receive):
            switch receive {
            case let .banner(banner):
                state.destination = .banner(banner)
                
            case let .list(list):
                state.destination = .list(list)
            }
            
        case let .select(select):
            state.isLoading = true
            state.destination = nil

            switch select {                
            case let .banner(banner):
                effect = .showBanner(banner)
                
            case let .list(banners):
                effect = .showAll(banners)
            }
        }
        
        return (state, effect)
    }
}

public extension BannerPickerSectionFlowReducer {
    
    typealias State = BannerPickerSectionFlowState<SelectedBanner, BannerList>
    typealias Event = BannerPickerSectionFlowEvent<Banner, SelectedBanner, BannerList>
    typealias Effect = BannerPickerSectionFlowEffect<Banner>
}
