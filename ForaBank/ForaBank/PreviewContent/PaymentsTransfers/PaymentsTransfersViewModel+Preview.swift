//
//  Payments&TransfersViewModel+Preview.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 15.05.2022.
//

import SwiftUI

extension LatestPaymentsViewComponent.ViewModel {
    
    static let sample: LatestPaymentsViewComponent.ViewModel = {
        
        typealias ViewModel = LatestPaymentsViewComponent.ViewModel
        
        let latestPaymentsButtons: [LatestPaymentButtonVM] =
            
        [
            .init(id: 1,
                  avatar: .image(Image("contactPlaceholder")),
                  topIcon: Image("beline"),
                  description: "Любимая Diamond",
                  action: {}),
            .init(id: 2,
                  avatar: .text("АБ"),
                  topIcon: Image("Bank Logo Sample"),
                  description: "Андрей Брат",
                  action: {}),
            .init(id: 3,
                  avatar: .icon(Image("ic24Smartphone"), .iconGray),
                  topIcon: Image("Bank Logo Sample"),
                  description: "+7 (903) 333-67-32",
                  action: {}),
            .init(id: 4,
                  avatar: .text("ЭА"),
                  topIcon: Image("azerFlag"),
                  description: "Эмин Агаларов",
                  action: {}),
            .init(id: 5,
                  avatar: .icon(Image("ic24Smartphone"), .iconGray),
                  topIcon: Image("azerFlag"),
                  description: "+994 12 493 23 87",
                  action: {})
        ]
        
        let items = latestPaymentsButtons.map { ItemViewModel.latestPayment($0) }
        
        let latestPaymentsVM = ViewModel(titleHidden: false, items: items, model: .emptyMock)
        let baseButtons = latestPaymentsVM.baseButtons.map { ItemViewModel.templates($0) }
        latestPaymentsVM.items = baseButtons + latestPaymentsVM.items
        return latestPaymentsVM
        
    }()
}

extension PTSectionTransfersView.ViewModel {
            
    static let transfersButtonsExample: [TransfersButtonVM]  = {
        [
            .init(type: .byPhoneNumber, action: {}),
            .init(type: .betweenSelf, action: {}),
            .init(type: .abroad, action: {}),
            .init(type: .anotherCard, action: {}),
            .init(type: .byBankDetails, action: {})
        ]
    }()
}

extension PTSectionPaymentsView.ViewModel {
            
    static let paymentButtonsData: [PaymentButtonVM]  = {
        [
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
    }()
}

extension PaymentsTransfersViewModel {
            
    static let sample: PaymentsTransfersViewModel = {
        typealias ViewModel = PaymentsTransfersViewModel
        
        let sections: [PaymentsTransfersSectionViewModel] =
        [
            LatestPaymentsViewComponent.ViewModel(
                titleHidden: false, items: LatestPaymentsViewComponent.ViewModel.sample.items,
                model: .emptyMock
            ),
          
            PTSectionTransfersView.ViewModel(transfersButtons:
                PTSectionTransfersView.ViewModel.transfersButtonsExample),
            
            PTSectionPaymentsView.ViewModel(paymentButtons:
                PTSectionPaymentsView.ViewModel.paymentButtonsData)
        ]
        
        return .init(sections: sections,
                     model: .emptyMock,
                     navButtonsRight:
                        [.init(icon: .ic24BarcodeScanner2,
                               action: {} ) ])
    }()
    
}
