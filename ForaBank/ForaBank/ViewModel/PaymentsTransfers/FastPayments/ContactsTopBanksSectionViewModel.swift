//
//  ContactsTopBanksSectionViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import SwiftUI
import Combine

class ContactsTopBanksSectionViewModel: ObservableObject {
    
    @Published var content: ContentType
    
    private let model: Model
    var bindings = Set<AnyCancellable>()
    
    init(_ model: Model, content: ContentType) {
        
        self.model = model
        self.content = content
    }
    
    convenience init(_ model: Model) {
        
        let content: ContentType = .placeHolder(.init())
        self.init(model, content: content)
    }
    
    enum ContentType {
        
        case banks(TopBanksViewModel)
        case placeHolder(PlaceHolderViewModel)
    }
}

struct PlaceHolderViewModel {
    
    let count = 6
}

class TopBanksViewModel: ObservableObject, Equatable {

    @Published var banks: [Bank]
    
    init(banks: [Bank]) {
        
        self.banks = banks
    }
    
    struct Bank: Hashable, Identifiable {
        
        let id = UUID()
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
