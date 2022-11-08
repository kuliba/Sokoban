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
    
    enum ContentType {
        
        case banks(TopBanksViewModel?)
        case placeHolder([LatestPaymentsView.ViewModel.PlaceholderViewModel])
    }
    
    init(_ model: Model, content: ContentType) {
        
        self.model = model
        self.content = content
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    convenience init(_ model: Model, selectPhone: String) {
        
        let content: ContentType = .placeHolder(.init(repeating: .init(), count: 6))
        self.init(model, content: content)

        bind(with: selectPhone)
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    private func bind(with selectPhone: String) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.LatestPayments.BanksList.Response:
                    
                    switch payload.result {
                    case .success(let banks):

                        let banks = Self.reduce(model: model, selectPhone: selectPhone, banks: banks, action: { [weak self] bankId in

                            
                            { self?.action.send(ContactsTopBanksSectionViewModelAction.TopBanksDidTapped(bankId: bankId)) }
                        })

                        if let banks = banks {
                            
                            self.content = .banks(banks)
                        }
                        
                    case .failure:
                        self.content = .banks(nil)
                    }
                default: break
                }
            }.store(in: &bindings)
    }
    
    static func reduce(model: Model, selectPhone: String, banks: [PaymentPhoneData], action: @escaping ((String) -> () -> Void)) -> TopBanksViewModel? {
        
        var banksList: [TopBanksViewModel.Bank] = []
        
        for bank in banks {
            
            if let bankName = bank.bankName, let defaultBank = bank.defaultBank, let payment = bank.payment, let bankId = bank.bankId  {

                let contact = payment ? model.contact(for: selectPhone) : nil
                banksList.append(TopBanksViewModel.Bank(image: getImageBank(model: model, paymentBank: bank), defaultBank: defaultBank, name: contact?.fullName, bankName: bankName, action: action(bankId)))
            }
        }
        
        func getImageBank(model: Model, paymentBank: PaymentPhoneData) -> Image? {
            
            let banks = model.bankList.value
            for bank in banks {
                
                if paymentBank.bankId == bank.memberId {
                    
                    return bank.svgImage.image
                }
            }
            
            return nil
        }
        
        return TopBanksViewModel(banks: banksList)
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
            
            lhs.id == rhs.id && lhs.name == rhs.name
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
            hasher.combine(name)
        }
    }
    
    static func == (lhs: TopBanksViewModel, rhs: TopBanksViewModel) -> Bool {
        lhs.banks == rhs.banks
    }
}

struct ContactsTopBanksSectionViewModelAction {
    
    struct TopBanksDidTapped: Action {
        
        let bankId: String
    }
}
