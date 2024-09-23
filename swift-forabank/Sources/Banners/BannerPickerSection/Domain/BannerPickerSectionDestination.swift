//
//  BannerPickerSectionDestination.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

public enum BannerPickerSectionDestination<SelectedBanner, BannerList> {
    
    case banner(SelectedBanner)
    case list(BannerList)
}

extension BannerPickerSectionDestination: Equatable where SelectedBanner: Equatable, BannerList: Equatable {}
