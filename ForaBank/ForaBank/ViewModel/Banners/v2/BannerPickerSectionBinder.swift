//
//  BannerPickerSectionBinder.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.09.2024.
//

import Banners

typealias BannerPickerSectionBinder = Banners.BannerPickerSectionBinder<BannerCatalogListData, SelectedBannerDestination, BannerListModelStub>

final class SelectedBannerStub {
    
    let banner: BannerCatalogListData

    init(
        banner: BannerCatalogListData
    ) {
        self.banner = banner
    }
}

final class BannerListModelStub {
    
    let banners: [BannerCatalogListData]
    
    init(banners: [BannerCatalogListData]) {
     
        self.banners = banners
    }
}
