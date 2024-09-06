//
//  RootViewModelFactory+makeLoadBannersList.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.09.2024.
//

import PayHubUI

typealias LoadBannersCompletion = ([CategoryPickerSectionItem<BannerCatalogListData>]) -> Void
typealias LoadBannersCategories = (@escaping LoadBannersCompletion) -> Void

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
                                                                                                                                                            
