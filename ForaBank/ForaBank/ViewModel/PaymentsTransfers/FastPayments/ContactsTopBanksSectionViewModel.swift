//
//  ContactsTopBanksSectionViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import SwiftUI

class TopBanksViewModel: Equatable {
    
//    @Published var content: ContentType
//
//    enum ContentType {
//        
//        case banks(TopBanksViewModel)
//        case placeHolder(PlaceHolderViewModel)
//    }

    @Published var banks: [Bank]
    
    init(banks: [Bank]) {
        
        self.banks = banks
    }
    
    struct PlaceHolderViewModel {
        
    }
    
    struct Bank: Hashable {
        
        let image: Image?
        let defaultBank: Bool
        let name: String?
        let bankName: String
        let action: () -> Void
        
        init(image: Image?, defaultBank: Bool, name: String?, bankName: String, action: @escaping () -> Void) {
            
            self.image = image
            self.name = name
            self.defaultBank = defaultBank
            self.bankName = bankName
            self.action = action
        }
        
        static func == (lhs: Bank, rhs: Bank) -> Bool {
            
            lhs.name == rhs.name
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(name)
        }
    }
    
    static func == (lhs: TopBanksViewModel, rhs: TopBanksViewModel) -> Bool {
        lhs.banks == rhs.banks
    }
}
