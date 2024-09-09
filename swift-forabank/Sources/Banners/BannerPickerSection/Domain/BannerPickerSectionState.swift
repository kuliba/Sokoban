//
//  BannerPickerSectionState.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

public struct BannerPickerSectionFlowState<SelectedBanner, BannerList> {
    
    public var isLoading: Bool
    public var destination: Destination?
    
    public init(
        isLoading: Bool = false,
        destination: Destination? = nil
    ) {
        self.isLoading = false
        self.destination = destination
    }
}

public extension BannerPickerSectionFlowState {
    
    typealias Destination = BannerPickerSectionDestination<SelectedBanner, BannerList>
}

extension BannerPickerSectionFlowState: Equatable where SelectedBanner: Equatable, BannerList: Equatable {}
