//
//  BannersContentViewFactory.swift
//
//
//  Created by Andryusina Nataly on 17.09.2024.
//

public struct BannersContentViewFactory<BannerPicker, BannerSectionView> {
    
    public let makeBannerSectionView: MakeBannerSectionView
    
    public init(
        makeBannerSectionView: @escaping MakeBannerSectionView
    ) {
        self.makeBannerSectionView = makeBannerSectionView
    }
}

public extension BannersContentViewFactory {
    
    typealias MakeBannerSectionView = (BannerPicker) -> BannerSectionView
}
