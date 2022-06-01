//
//  Payments&TransfersViewModel+Preview.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 15.05.2022.
//

import SwiftUI

extension PTSectionLatestPaymentsView.ViewModel {
    
    static let sample: PTSectionLatestPaymentsView.ViewModel = {
        
        typealias ViewModel = PTSectionLatestPaymentsView.ViewModel
        
        let latestPaymentsButtons: [LatestPaymentButtonVM] =
            
        [
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
        
        let latestPaymentsVM = ViewModel(latestPaymentsButtons: latestPaymentsButtons, model: .emptyMock)
        latestPaymentsVM.latestPaymentsButtons = latestPaymentsVM.templateButton
                                               + latestPaymentsVM.latestPaymentsButtons
        return latestPaymentsVM
        
    }()
}

extension PaymentsTransfersViewModel {
    
    static let sample: PaymentsTransfersViewModel = {
        
        typealias ViewModel = PaymentsTransfersViewModel
        
        let sections: [PaymentsTransfersSectionViewModel] =
        [
            PTSectionLatestPaymentsView.ViewModel(
                latestPaymentsButtons: PTSectionLatestPaymentsView.ViewModel.sample.latestPaymentsButtons,
                model: .emptyMock
            ),
          
            PTSectionTransfersView.ViewModel(transfersButtons:
                PTSectionTransfersView.ViewModel.transfersButtonsData),
            
            PTSectionPayGroupView.ViewModel(payGroupButtons:
                PTSectionPayGroupView.ViewModel.payGroupButtonsData)
        ]
        
        return .init(sections: sections, model: .emptyMock)
    }()
    
}
