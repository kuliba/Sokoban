//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import SwiftUI

class PaymentsTransfersViewModel: ObservableObject {
    
    @Published var sections: [PaymentsTransfersSectionViewModel]
    
    private let model: Model
    
    init(model: Model) {
        self.sections = [
            PTSectionLatestPaymentsView.ViewModel(model: model),
            PTSectionTransfersView.ViewModel(),
            PTSectionPayGroupView.ViewModel()
        ]
        self.model = model
   }

    init(sections: [PaymentsTransfersSectionViewModel], model: Model) {
            self.sections = sections
            self.model = model
        }
    

}

