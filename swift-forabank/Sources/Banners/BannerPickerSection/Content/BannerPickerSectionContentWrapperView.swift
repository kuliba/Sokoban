//
//  BannerPickerSectionContentWrapperView.swift
//  
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import RxViewModel
import SwiftUI

public typealias BannerPickerSectionContentWrapperView<ContentView, ServiceBanner> = RxWrapperView<ContentView, BannerPickerSectionState<ServiceBanner>, BannerPickerSectionEvent<ServiceBanner>, BannerPickerSectionEffect> where ContentView: View
