//
//  BannerPickerSectionFlowEvent.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

public enum BannerPickerSectionFlowEvent<Banner, SelectedBanner, BannerList> {
    
    case dismiss
    case receive(Receive)
    case select(Select)
}

public extension BannerPickerSectionFlowEvent {
    
    enum Receive {
        
        case banner(SelectedBanner)
        case list(BannerList)
    }
    
    enum Select {
        
        case banner(Banner)
        case list([Banner])
    }
}

extension BannerPickerSectionFlowEvent: Equatable where Banner: Equatable, SelectedBanner: Equatable, BannerList: Equatable {}
extension BannerPickerSectionFlowEvent.Receive: Equatable where SelectedBanner: Equatable, BannerList: Equatable {}
extension BannerPickerSectionFlowEvent.Select: Equatable where Banner: Equatable, BannerList: Equatable {}
