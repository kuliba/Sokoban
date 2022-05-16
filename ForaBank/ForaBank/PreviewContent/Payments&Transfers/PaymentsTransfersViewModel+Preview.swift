//
//  Payments&TransfersViewModel+Preview.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 15.05.2022.
//

import SwiftUI

extension PaymentsTransfersViewModel {
    
    static let sample: PaymentsTransfersViewModel = {
        
        typealias ViewModel = PaymentsTransfersViewModel
        
        let latestPaymentsButtons: [LatestPaymentButtonVM] = ViewModel.templateButtonData + [
       
            .init(image: .image(Image("contactPlaceholder")),
                  topIcon: Image("beline"),
                  description: "Любимая Diamond",
                  action: {}),
            .init(image: .text("АБ"),
                  topIcon: Image("Bank Logo Sample"),
                  description: "Андрей Брат",
                  action: {}),
            .init(image: .icon(Image("ic24Smartphone"), .iconGray),
                  topIcon: Image("Bank Logo Sample"),
                  description: "+7 (903) 333-67-32",
                  action: {}),
            .init(image: .text("ЭА"),
                  topIcon: Image("azerFlag"),
                  description: "Эмин Агаларов",
                  action: {}),
            .init(image: .icon(Image("ic24Smartphone"), .iconGray),
                  topIcon: Image("azerFlag"),
                  description: "+994 12 493 23 87",
                  action: {})
        ]
        
        return .init(latestPaymentsSectionTitle: "Платежи",
                     transfersSectionTitle: "Перевести",
                     paySectionTitle: "Оплатить",
                     latestPaymentsButtons: latestPaymentsButtons,
                     transferButtons: ViewModel.transferButtonsData,
                     payGroupButtons: ViewModel.payGoupButtonsData,
                     model: .emptyMock)
    }()
    
}
