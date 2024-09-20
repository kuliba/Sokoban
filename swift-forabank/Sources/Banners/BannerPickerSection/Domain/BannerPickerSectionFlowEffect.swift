//
//  BannerPickerSectionFlowEffect.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

public enum BannerPickerSectionFlowEffect<Banner> {
    
    case showAll([Banner])
    case showBanner(Banner)
}

extension BannerPickerSectionFlowEffect: Equatable where Banner: Equatable {}
