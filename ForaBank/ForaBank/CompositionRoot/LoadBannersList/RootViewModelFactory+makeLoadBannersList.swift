//
//  RootViewModelFactory+makeLoadBannersList.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.09.2024.
//

import Banners

typealias LoadBannersCompletion = ([BannerPickerSectionItem<BannerCatalogListData>]) -> Void
typealias LoadBanners = (@escaping LoadBannersCompletion) -> Void

extension RootViewModelFactory {
    
    typealias LoadBannersListCompletion = (Result<[BannerCatalogListData], Error>) -> Void
    typealias LoadBannersList = (@escaping LoadBannersListCompletion) -> Void

    static func makeLoadBannersList(
        getBannersList: @escaping (@escaping LoadBannersListCompletion) -> Void
    ) -> LoadBannersList {
        
        return { completion in
            
            getBannersList(completion)
        }
    }
}
