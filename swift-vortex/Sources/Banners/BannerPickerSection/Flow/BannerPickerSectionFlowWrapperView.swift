//
//  BannerPickerSectionFlowWrapperView.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias BannerPickerSectionFlowWrapperView<ContentView, Banner, SelectedBanner, BannerList> = RxWrapperView<ContentView, BannerPickerSectionFlowState<SelectedBanner, BannerList>, BannerPickerSectionFlowEvent<Banner, SelectedBanner, BannerList>, BannerPickerSectionFlowEffect<Banner>> where ContentView: View
