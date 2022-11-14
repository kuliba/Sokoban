//
//  ContactsLatestPaymentsViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 14.11.2022.
//

import Foundation
import SwiftUI
import Combine

class ContactsLatestPaymentsViewModel: ContactsSectionViewModel, ObservableObject {
    
    override var type: ContactsSectionViewModel.Kind { .latestPayments }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum LatestPayments {
        
        struct ItemDidTapped: Action {
            
            let latestPayment: LatestPaymentData
        }
    }
}
