//
//  AuthLoginViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 07.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthLoginViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()

    let header: HeaderViewModel

    lazy var card: CardViewModel = {

        CardViewModel(scanButton: .init(action:

            {
                self.action.send(AuthLoginViewModelAction.Show.Scaner())
            }),

                      nextButton:  .init(action:

            {
                guard let cardNumber = self.card.cardNumber else { return }
                self.action.send(AuthLoginViewModelAction.Auth(cardNumber: cardNumber))
            }))
    }()

    lazy var productsButton: ProductsButtonViewModel = {

        ProductsButtonViewModel(action: {
            self.action.send(AuthLoginViewModelAction.Show.Products())
        })
    }()

    init() {

        self.header = HeaderViewModel()
    }
}

extension AuthLoginViewModel {
    
    struct HeaderViewModel {
        
        let title = "Войти"
        let subTitle = "чтобы получить доступ к счетам и картам"
        let icon = Image.ic16ArrowDown
    }

    class CardViewModel: ObservableObject {

        let icon = Image.ic32LogoForaLine
        let scanButton: ScanButtonViewModel
        @Published var cardNumber: String?
        @Published var nextButton: NextButtonViewModel
        let subTitle = "Введите номер вашей карты или счета"

        internal init(scanButton: ScanButtonViewModel, nextButton: NextButtonViewModel) {

            self.scanButton = scanButton
            self.nextButton = nextButton
        }

        struct ScanButtonViewModel {

            let icon = Image.ic24SkanCard
            let action: () -> Void
        }

        struct NextButtonViewModel {

            let icon = Image.ic24ArrowRight
            let action: () -> Void
        }
    }

    struct ProductsButtonViewModel {

        let icon = Image.ic40Card
        let title = "Нет карты?"
        let subTitle = "Доставим в любую точку"
        let arrowRight = Image.ic24ArrowRight
        let action: () -> Void
    }
}

enum AuthLoginViewModelAction {

    struct Auth: Action {

        let cardNumber: String
    }

    enum Show {

        struct Scaner: Action { }
        
        struct Products: Action { }
    }
}
