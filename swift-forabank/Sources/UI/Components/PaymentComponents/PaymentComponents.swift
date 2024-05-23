//
//  PaymentComponents.swift
//
//
//  Created by Igor Malyarov on 23.12.2023.
//

@_exported import AmountComponent
@_exported import ButtonComponent
@_exported import CarouselComponent
@_exported import FooterComponent
@_exported import InputComponent
@_exported import InputPhoneComponent
@_exported import InfoComponent
@_exported import NameComponent
@_exported import CheckBoxComponent
@_exported import ProductSelectComponent
@_exported import SharedConfigs
@_exported import OTPInputComponent

/// A namespace for Payment Components.
///
/// For discoverability, code auto-completion and consistency.
///
///     PaymentComponents.AmountView
///
public enum PaymentComponents {}

public extension PaymentComponents {
    
    typealias Amount = AmountComponent.Amount
    typealias AmountConfig = AmountComponent.AmountConfig
    typealias AmountView = AmountComponent.AmountView
    
    typealias CodeView = OTPInputComponent.CodeInputView
    typealias CodeConfig = OTPInputComponent.CodeInputConfig

    typealias Button = ButtonComponent.Button
    typealias ButtonConfig = SharedConfigs.ButtonConfig
    typealias ButtonStateConfig = SharedConfigs.ButtonStateConfig
    typealias ButtonView = ButtonComponent.ButtonView
    
    typealias Info = InfoComponent.Info
    typealias InfoConfig = InfoComponent.InfoConfig
    typealias InfoView = InfoComponent.InfoView
    typealias PublishingInfo = InfoComponent.PublishingInfo
    typealias PublishingInfoView = InfoComponent.PublishingInfoView
    
    typealias InputView = InputComponent.InputView
    typealias InputConfig = InputComponent.InputConfig
    
    typealias InputPhoneView = InputPhoneComponent.InputPhoneView
    typealias InputPhoneConfig = InputPhoneComponent.InputPhoneConfig
    
    typealias ProductSelect = ProductSelectComponent.ProductSelect
    typealias ProductSelectConfig = ProductSelectComponent.ProductSelectConfig
    typealias ProductSelectView = ProductSelectComponent.ProductSelectView

    typealias ProductCard = ProductSelectComponent.ProductCard
    typealias ProductCardConfig = ProductSelectComponent.ProductCardConfig
    typealias ProductCardView = ProductSelectComponent.ProductCardView
    
    typealias CheckBox = CheckBoxComponent.CheckBoxView
    typealias CheckBoxConfig = CheckBoxComponent.CheckBoxView.Config
    
    typealias NameView = NameComponent.NameView
    typealias NameConfig = InputComponent.InputConfig
    
    typealias FooterView = FooterComponent.FooterView
    typealias FooterConfig = FooterComponent.FooterView.Config
}
