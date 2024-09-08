//
//  BannerPickerSectionContent.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import Foundation
import PayHub
import RxViewModel

public enum BannerPickerSectionItem<ServiceBanner> {
    
    case banner(ServiceBanner)
    case showAll
}

extension BannerPickerSectionItem: Equatable where ServiceBanner: Equatable {}

public typealias BannerPickerSectionState<ServiceBanner> = LoadablePickerState<UUID, BannerPickerSectionItem<ServiceBanner>>
public typealias BannerPickerSectionEvent<ServiceBanner> = LoadablePickerEvent<BannerPickerSectionItem<ServiceBanner>>
public typealias BannerPickerSectionEffect = LoadablePickerEffect

public typealias BannerPickerSectionReducer<ServiceBanner> = LoadablePickerReducer<UUID, BannerPickerSectionItem<ServiceBanner>>
public typealias BannerPickerSectionEffectHandler<ServiceBanner> = LoadablePickerEffectHandler<BannerPickerSectionItem<ServiceBanner>>

public typealias BannerPickerSectionContent<ServiceBanner> = RxViewModel<BannerPickerSectionState<ServiceBanner>, BannerPickerSectionEvent<ServiceBanner>, BannerPickerSectionEffect>
