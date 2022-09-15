//
//  PaymentsSuccessMock.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 15.09.2022.
//

// MARK: - Option Button

extension PaymentsSuccessOptionButtonViewModel {
    
    typealias OptionButtonViewModel = PaymentsSuccessOptionButtonView.ViewModel
    
    static let sample1: OptionButtonViewModel = .init(icon: .ic24Star, title: "Шаблон", action: {})
    static let sample2: OptionButtonViewModel = .init(icon: .ic24File, title: "Документ", action: {})
    static let sample3: OptionButtonViewModel = .init(icon: .ic24Info, title: "Детали", action: {})
}

// MARK: - Option

extension PaymentsSuccessViewModel.OptionViewModel {
    
    typealias OptionViewModel = PaymentsSuccessViewModel.OptionViewModel
    
    static let sample1: OptionViewModel = .init(image: .ic24Clock, title: "Получатель", subTitle: "Тестовый QR Static для теста №501", description: "Цветы у дома")
    
    static let sample2: OptionViewModel = .init(image: .ic24Coins, title: "Сумма операции", subTitle: nil, description: "16 006,22 ₽")
}

// MARK: - ViewModel

extension PaymentsSuccessViewModel {
    
    static let sample1: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .success, title: "Успешный перевод", amount: 1000, optionButtons: [.sample1, .sample2, .sample3], dismissAction: {}
    )
    
    static let sample2: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .accepted, title: "Платеж принят в обработку", amount: 1000, optionButtons: [.sample1, .sample3], dismissAction: {}
    )
    
    static let sample3: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .error, title: "Операция неуспешна!", amount: 1000, optionButtons: [.sample3], repeatButton: .init(title: "Повторить", style: .gray, action: {}), dismissAction: {}
    )
    
    static let sample4: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .accepted, title: "Платеж принят в обработку", amount: 1000, options: nil, logo: .init(title: "сбп", image: .ic40Sbp), warningTitle: nil, optionButtons: [.sample3], dismissAction: {}
    )
    
    static let sample5: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .accepted, title: "Операция в обработке!", amount: nil, options: [.sample1, .sample2], logo: .init(title: "сбп", image: .ic40Sbp), warningTitle: nil, optionButtons: [.sample2, .sample3], dismissAction: {}
    )
    
    static let sample6: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .accepted, title: "Время на подтверждение перевода вышло", amount: 1000, options: nil, logo: .init(title: "сбп", image: .ic40Sbp), warningTitle: "Перевод отменен!", optionButtons: [], dismissAction: {}
    )
    
    static let sample7: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .accepted, title: nil, amount: 1000, options: nil, logo: .init(title: "сбп", image: .ic40Sbp), warningTitle: "Перевод отменен!", optionButtons: [], dismissAction: {}
    )
    
    static let sample8: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .accepted, title: "Запрос на пополнение со своего счета принят", amount: 500, service: .init(title: "Из банка:", description: "Сбербанк"), optionButtons: [], logo: .init(title: "сбп", image: .ic40Sbp), dismissAction: {}
    )
    
    static let sample9: PaymentsSuccessViewModel = .init(.emptyMock, iconType: .accepted, title: "Запрос на пополнение со своего счета принят в обработку", amount: 500, service: .init(title: "Из банка:", description: "Сбербанк"), optionButtons: [], logo: .init(title: "сбп", image: .ic40Sbp), dismissAction: {}
    )
}
