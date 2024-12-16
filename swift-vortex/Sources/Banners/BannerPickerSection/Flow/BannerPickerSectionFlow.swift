//
//  BannerPickerSectionFlow.swift
//  
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import PayHub
import RxViewModel

public typealias BannerPickerSectionFlow<Banner, SelectedBanner, BannerList> = RxViewModel<BannerPickerSectionFlowState<SelectedBanner, BannerList>, BannerPickerSectionFlowEvent<Banner, SelectedBanner, BannerList>, BannerPickerSectionFlowEffect<Banner>>
