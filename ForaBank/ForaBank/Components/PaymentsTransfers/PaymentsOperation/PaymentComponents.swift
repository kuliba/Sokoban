//
//  PaymentComponents.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.05.2023.
//

/// A namespace for Payment Components.
enum PaymentComponents {}

/// For discoverability, code auto-completion and consistency.
///
///     PaymentComponents.SwitchView
///
extension PaymentComponents {
    
    // TODO:
    //    PaymentsContinueButtonView -> PaymentsButtonView (но она пока живет в ветке с привязкой счета)
    //    PaymentsSelectSimpleView -> PaymentsSelectView
    //    PaymentsSwitchView -> PaymentSelectDropDownView (нужно переименовать в `PaymentsSelectDropDownView`)
    //    PaymentsSwitchView -> PaymentSelectDropDownView (нужно переименовать в `PaymentsSelectDropDownView`)
    //    PaymetnsSubscribeVeiw -> нужно заменить на две PaymentsButtonView в группе (но это пока в ветке с привязкой счета)
    //
    //    PaymetnsSelectView - используется
    //    PaymetnsSpoilerButtonView - используется
    
    typealias AmountView = ForaBank.PaymentsAmountView
    typealias CheckView = ForaBank.PaymentsCheckView
    typealias CodeView = ForaBank.PaymentsCodeView
    @available(*, deprecated, message: "Use PaymentsButtonView instead")
    typealias ContinueButtonView = ForaBank.PaymentsContinueButtonView
    typealias InfoView = ForaBank.PaymentsInfoView
    typealias InputPhoneView = ForaBank.PaymentsInputPhoneView
    typealias InputView = ForaBank.PaymentsInputView
    typealias MessageView = ForaBank.PaymentsMessageView
    typealias NameView = ForaBank.PaymentsNameView
    typealias ProductTemplateView = ForaBank.PaymentsProductTemplateView
    typealias ProductView = ForaBank.PaymentsProductView
    typealias SelectBankView = ForaBank.PaymentsSelectBankView
    typealias SelectCountryView = ForaBank.PaymentsSelectCountryView
    typealias SelectDropDownView = ForaBank.PaymentSelectDropDownView
    typealias SelectServiceView = ForaBank.PaymentsSelectServiceView
    @available(*, deprecated, message: "Use PaymetnsSelectView instead")
    typealias SelectSimpleView = ForaBank.PaymentsSelectSimpleView
    typealias SelectView = ForaBank.PaymentsSelectView
    typealias SpoilerButtonView = ForaBank.PaymentsSpoilerButtonView
    typealias SubscriberView = ForaBank.PaymentsSubscriberView
    typealias SubscribeView = ForaBank.PaymentsSubscribeView
    @available(*, deprecated, message: "Use ??????? instead")
    typealias SwitchView = ForaBank.PaymentsSwitchView
}
