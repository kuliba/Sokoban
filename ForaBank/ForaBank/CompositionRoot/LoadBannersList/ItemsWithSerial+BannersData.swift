//
//  ItemsWithSerial+BannersData.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.09.2024.
//

import Foundation

typealias BannersData = ServerCommands.DictionaryController.GetBannerCatalogList.Response.BannerCatalogData

extension ItemsWithSerial {
    
    init (_ banners: BannersData) {
        
        self.init(serial: banners.serial, items: banners.bannerCatalogList)
    }
}
