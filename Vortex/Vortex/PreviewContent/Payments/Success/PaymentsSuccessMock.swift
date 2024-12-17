//
//  PaymentsSuccessMock.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 15.09.2022.
//

// TODO: extract AnySchedulerOfDispatchQueue into a separate module
import TextFieldModel

// MARK: - Option Button

extension ButtonSimpleView.ViewModel {
    
    static let sample: ButtonSimpleView.ViewModel = .init(title: "На главную", style: .red, action: {})
}

// MARK: - ViewModel

extension PaymentsSuccessViewModel {
    
    static let sample1: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .success),
                Payments.ParameterSuccessAdditionalButtons(options: [.change, .return]),
                Payments.ParameterSuccessText(value: "Успешный перевод", style: .title),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessTransferNumber(number: "1234567890"),
                Payments.ParameterSuccessOptionButtons(
                    options: [.template, .document, .details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample2: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Платеж принят в обработку", style: .title),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptionButtons(
                    options: [.template, .details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample3: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Операция неуспешна!", style: .title),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptionButtons(
                    options: [.details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton(title: "Повторить", style: .secondary, acton: .repeat, placement: .bottom),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample4: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Платеж принят в обработку", style: .title),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptionButtons(
                    options: [.details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample5: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Операция в обработке!", style: .title),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptions(
                    options: [
                        .init(icon: .name("ic24Clock"), title: "Получатель", subTitle: "Тестовый QR Static для теста №501", description: "Цветы у дома"),
                        .init(icon: .name("ic24Coins"), title: "Сумма операции", subTitle: nil, description: "16 006,22 ₽")
                    ]),
                Payments.ParameterSuccessOptionButtons(
                    options: [.details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample6: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Время на подтверждение перевода вышло", style: .title),
                Payments.ParameterSuccessText(value: "Перевод отменен!", style: .warning),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptions(
                    options: [
                        .init(icon: .name("ic24Clock"), title: "Получатель", subTitle: "Тестовый QR Static для теста №501", description: "Цветы у дома"),
                        .init(icon: .name("ic24Coins"), title: "Сумма операции", subTitle: nil, description: "16 006,22 ₽")
                    ]),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample7: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Перевод отменен!", style: .title),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample8: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Запрос на пополнение со своего счета принят", style: .title),
                Payments.ParameterSuccessService(title: "Из банка:", description: "Сбербанк"),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample9: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Запрос на пополнение со своего счета принят", style: .title),
                Payments.ParameterSuccessService(title: "Из банка:", description: "Сбербанк"),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let sample10: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .success),
                Payments.ParameterSuccessText(value: "Привязка счета оформлена", style: .title),
                Payments.ParameterSubscriber(.init(id: "subscriberParamID", value: "Цветы у дома"), icon: "iconHash", description: nil, style: .small),
                Payments.ParameterSuccessLink(parameterId: "linkParamID", title: "Вернуться в магазин", url: .init(string: "https://www.google.com")!),
                Payments.ParameterButton.actionButtonMain(),
                Payments.ParameterSuccessIcon(icon: .name("ic72Sbp"), size: .normal, placement: .bottom)
            ]), .emptyMock)
    
    static let previewMobileConnectionOk: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .success),
                Payments.ParameterSuccessText(value: "Успешный перевод", style: .title),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptionButtons(
                    options: [.template, .document, .details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let previewMobileConnectionAccepted: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .accepted),
                Payments.ParameterSuccessText(value: "Операция в обработке!", style: .title),
                Payments.ParameterSuccessLogo(icon: .name("ic40Sbp"), title: "сбп"),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptionButtons(
                    options: [.template, .details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static let previewMobileConnectionFailed: PaymentsSuccessViewModel = .init(
        paymentSuccess: .init(
            operation: .emptyMock,
            parameters: [
                Payments.ParameterSuccessStatus(status: .error),
                Payments.ParameterSuccessText(value: "Операция неуспешна!", style: .title),
                Payments.ParameterSuccessText(value: "1 000 ₽", style: .amount),
                Payments.ParameterSuccessOptionButtons(
                    options: [.details],
                    templateID: nil,
                    meToMePayment: nil,
                    operation: nil
                ),
                Payments.ParameterButton.actionButtonMain()
            ]), .emptyMock)
    
    static func fraudCancelled(
        goToMain: @escaping () -> Void
    ) -> PaymentsSuccessViewModel {
        
        return .init(
            model: .emptyMock,
            sections: [
                .top(groups: []),
                .feed(groups: [
                    .init(items: [
                        PaymentsSuccessStatusView.ViewModel(
                            icon: .init("waiting"),
                            color: .systemColorWarning
                        ),
                        PaymentsSuccessTextView.ViewModel(.init(value: "Cancelled", style: .warning))
                    ])
                ]),
                .bottom(groups: [
                    .init(items: [
                        PaymentsButtonView.ViewModel(button: .init(
                            title: "На главный",
                            style: .red,
                            action: goToMain
                        ))
                    ])
                ])
            ]
        )
    }
    
    static let fraudExpired: PaymentsSuccessViewModel = .init(
        model: .emptyMock,
        sections: [
            
        ]
    )
}

extension PaymentsSectionViewModel {
    
    static func bottom(
        groups: [PaymentsGroupViewModel]
    ) -> PaymentsSectionViewModel {
        
        return .init(placement: .bottom, groups: groups)
    }

    static func feed(
        groups: [PaymentsGroupViewModel]
    ) -> PaymentsSectionViewModel {
        
        return .init(placement: .feed, groups: groups)
    }

    static func top(
        groups: [PaymentsGroupViewModel]
    ) -> PaymentsSectionViewModel {
        
        return .init(placement: .top, groups: groups)
    }
}

extension PaymentsSuccessViewModel {
    
    convenience init(
        model: Model,
        sections: [PaymentsSectionViewModel],
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        let mapper = PaymentsSectionViewModel.reduce(success:model:)
        let adapter = PaymentsSuccessViewModelAdapter(model: model, mapper: mapper, scheduler: scheduler)
        
        self.init(
            sections: sections,
            adapter: adapter,
            operation: nil,
            scheduler: scheduler
        )
    }
}
