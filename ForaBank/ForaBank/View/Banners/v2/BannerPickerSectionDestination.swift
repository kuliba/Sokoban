//
//  BannerPickerSectionDestination.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.09.2024.
//

import Banners

typealias BannerPickerSectionDestination = Banners.BannerPickerSectionDestination<SelectedBannerDestination, BannerListModelStub>

typealias SelectedBannerDestination = Banners.BannerFlow<StandardSelectedBannerDestination, StickerStub, LandingStub>


typealias StandardSelectedBannerDestination = Result<SelectedBannerStub, Error>

final class StickerStub {}
final class LandingStub {}
