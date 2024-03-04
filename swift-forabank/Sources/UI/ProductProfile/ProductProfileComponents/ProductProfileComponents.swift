//
//  ProductProfileComponents.swift
//  
//
//  Created by Andryusina Nataly on 03.03.2024.
//

import Foundation

@_exported import ActivateSlider
@_exported import CardGuardianUI
@_exported import TopUpCardUI
@_exported import AccountInfoPanel

/// A namespace
///
public enum ProductProfileComponents {}

public extension ProductProfileComponents {
    
    typealias ThumbConfig = ActivateSlider.ThumbConfig
    typealias SliderConfig = ActivateSlider.SliderConfig
    typealias SliderView = ActivateSlider.ActivateSliderWrapperView
    
    typealias CardGuardianCard = CardGuardianUI.Card
    typealias CardGuardianProduct = CardGuardianUI.Product
    typealias CardGuardianConfig = CardGuardianUI.CardGuardian.Config
    typealias CardGuardianView = CardGuardianUI.ThreeButtonsWrappedView
    
    typealias TopUpCard = TopUpCardUI.Card
    typealias TopUpCardConfig = TopUpCardUI.Config
    typealias TopUpCardView = TopUpCardUI.TopUpCardWrappedView
}
