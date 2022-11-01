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
    
    let action: PassthroughSubject<Action, Never> = .init()
    
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
        bind()
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.LatestPayments.BanksList.Response:
                    
                    switch payload.result {
                    case .success(let banks):
                        
                        let banks = self.reduce(model: model, banks: banks)
                        
                        if let banks = banks {
                            
                            self.content = .banks(banks)
                        }
                        
                    case .failure:
                        break
                    }
                default: break
                }
            }.store(in: &bindings)
    }
    
    func reduce(model: Model, banks: [PaymentPhoneData]) -> TopBanksViewModel? {
        
        let topBanksViewModel: TopBanksViewModel = .init(banks: [])
        
        var banksList: [TopBanksViewModel.Bank] = []
        
        banks.map({
            
            if let bankName = $0.bankName, let defaultBank = $0.defaultBank, let payment = $0.payment {
                
//                let contact = payment ? model.contact(for: self.searchBar.text ?? "") : nil
                banksList.append(TopBanksViewModel.Bank(image: getImageBank(model: model, paymentBank: $0), defaultBank: defaultBank, name: "contact?.fullName", bankName: bankName, action: { [weak self] in
                    
                    self?.action.send(ContactsTopBanksSectionViewModelAction.TopBanksDidTapped())
                }))
                
            } else {
                
                return
            }
        })
        
        topBanksViewModel.banks = banksList
        
        func getImageBank(model: Model, paymentBank: PaymentPhoneData) -> Image? {
            
            let banks = model.bankList.value
            for bank in banks {
                
                if paymentBank.bankId == bank.memberId {
                    
                    return bank.svgImage.image
                }
            }
            
            return nil
        }
        
        return topBanksViewModel
    }
    
    enum ContentType {
        
        case banks(TopBanksViewModel)
        case placeHolder([LatestPaymentsView.ViewModel.PlaceholderViewModel])
    }
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

struct ContactsTopBanksSectionViewModelAction {
    
    struct TopBanksDidTapped: Action {}
}
