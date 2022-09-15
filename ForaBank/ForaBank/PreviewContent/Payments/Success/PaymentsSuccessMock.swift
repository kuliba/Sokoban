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

extension ButtonSimpleView.ViewModel {
    
    static let sample: ButtonSimpleView.ViewModel = .init(title: "На главную", style: .red, action: {})
}

// MARK: - ViewModel

extension PaymentsSuccessViewModel {

    static let sample1: PaymentsSuccessViewModel = .init(iconType: .success, title: "Успешный перевод", amount: "1 000 ₽", optionButtons: [.sample1, .sample2, .sample3], actionButton: .sample
    )
    
    static let sample2: PaymentsSuccessViewModel = .init(iconType: .accepted, title: "Платеж принят в обработку", amount: "1 000 ₽", optionButtons: [.sample1, .sample3], actionButton: .sample
    )
    
    static let sample3: PaymentsSuccessViewModel = .init(iconType: .error, title: "Операция неуспешна!", amount: "1 000 ₽", repeatButton: .init(title: "Повторить", style: .gray, action: {}), optionButtons: [.sample3], actionButton: .sample
    )
    
    static let sample4: PaymentsSuccessViewModel = .init(iconType: .accepted, title: "Платеж принят в обработку", amount: "1 000 ₽", options: nil, logo: .init(title: "сбп", image: .ic40Sbp), optionButtons: [.sample3], actionButton: .sample
    )
    
    static let sample5: PaymentsSuccessViewModel = .init(iconType: .accepted, title: "Операция в обработке!", amount: nil, options: [.sample1, .sample2], logo: .init(title: "сбп", image: .ic40Sbp), warningTitle: nil, optionButtons: [.sample2, .sample3], actionButton: .sample
    )
    
    static let sample6: PaymentsSuccessViewModel = .init(iconType: .accepted, title: "Время на подтверждение перевода вышло", amount: "1 000 ₽", options: nil, logo: .init(title: "сбп", image: .ic40Sbp), warningTitle: "Перевод отменен!", optionButtons: [], actionButton: .sample
    )
    
    static let sample7: PaymentsSuccessViewModel = .init(iconType: .accepted, title: nil, amount: "1 000 ₽", options: nil, logo: .init(title: "сбп", image: .ic40Sbp), warningTitle: "Перевод отменен!", optionButtons: [], actionButton: .sample
    )
    
    static let sample8: PaymentsSuccessViewModel = .init(iconType: .accepted, title: "Запрос на пополнение со своего счета принят", amount: "500 ₽", service: .init(title: "Из банка:", description: "Сбербанк"), logo: .init(title: "сбп", image: .ic40Sbp), optionButtons: [], actionButton: .sample
    )
    
    static let sample9: PaymentsSuccessViewModel = .init(iconType: .accepted, title: "Запрос на пополнение со своего счета принят в обработку", amount: "500 ₽", service: .init(title: "Из банка:", description: "Сбербанк"), logo: .init(title: "сбп", image: .ic40Sbp), optionButtons: [], actionButton: .sample
    )
}
