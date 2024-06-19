//
//  Payments&TransfersViewModel+Preview.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 15.05.2022.
//

import SberQR
import SwiftUI

extension LatestPaymentsView.ViewModel {
    
    static let sample: LatestPaymentsView.ViewModel = {
        
        let latestPaymentsButtons: [LatestPaymentsView.ViewModel.LatestPaymentButtonVM] = .sample
        
        let items = latestPaymentsButtons.map(ItemViewModel.latestPayment)
        
        return .init(.emptyMock, items: items, isBaseButtons: true, filter: nil)
    }()
}

extension Array where Element == LatestPaymentsView.ViewModel.LatestPaymentButtonVM {
    
    static let sample: Self = [
        .init(id: 1,
              avatar: .image(Image("contactPlaceholder")),
              topIcon: Image("beline"),
              description: "Любимая Diamond",
              amount: "",
              action: {}),
        .init(id: 2,
              avatar: .text("АБ"),
              topIcon: Image("Bank Logo Sample"),
              description: "Андрей Брат",
              amount: "",
              action: {}),
        .init(id: 3,
              avatar: .icon(Image("ic24Smartphone"), .iconGray),
              topIcon: Image("Bank Logo Sample"),
              description: "+7 (903) 333-67-32",
              amount: "",
              action: {}),
        .init(id: 4,
              avatar: .text("ЭА"),
              topIcon: Image("azerFlag"),
              description: "Эмин Агаларов",
              amount: "",
              action: {}),
        .init(id: 5,
              avatar: .icon(Image("ic24Smartphone"), .iconGray),
              topIcon: Image("azerFlag"),
              description: "+994 12 493 23 87",
              amount: "",
              action: {}),
        .init(id: 6,
              avatar: .image(Image("ic40TvInternet")),
              topIcon: nil,
              description: "Интернет",
              amount: "",
              action: {}),
    ]
}

extension PaymentsTransfersViewModel {
    
    static let sample: PaymentsTransfersViewModel = .init(
        sections: [
            PTSectionLatestPaymentsView.ViewModel(
                model: .emptyMock
            ),
            PTSectionTransfersView.ViewModel(
                transfersButtons: .sample
            ),
            PTSectionPaymentsView.ViewModel(
                paymentButtons: .ample
            )
        ],
        model: .emptyMock,
        makeFlowManager: { _ in .preview },
        userAccountNavigationStateManager: .preview,
        sberQRServices: .empty(),
        qrViewModelFactory: .preview(), 
        paymentsTransfersFactory: .preview,
        navButtonsRight: [
            .init(icon: .ic24BarcodeScanner2, action: {})
        ]
    )
}

extension Array where Element == PTSectionTransfersView.ViewModel.TransfersButtonVM {
    
    static let sample: Self = [
        .init(type: .byPhoneNumber, action: {}),
        .init(type: .betweenSelf, action: {}),
        .init(type: .abroad, action: {}),
        .init(type: .anotherCard, action: {}),
        .init(type: .requisites, action: {})
    ]
}

extension Array where Element == PTSectionPaymentsView.ViewModel.PaymentButtonVM {
    
    static let ample: Self = [
        .init(type: .qrPayment, action: {}),
        .init(type: .mobile, action: {}),
        .init(type: .service, action: {}),
        .init(type: .internet, action: {}),
        .init(type: .transport, action: {}),
        .init(type: .taxAndStateService, action: {}),
        .init(type: .socialAndGame, action: {}),
        .init(type: .security, action: {}),
        .init(type: .others, action: {})
    ]
}
