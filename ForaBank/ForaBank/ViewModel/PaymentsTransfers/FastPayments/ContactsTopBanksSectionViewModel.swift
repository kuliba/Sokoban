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
    let phone: String
    
    private let model: Model
    var bindings = Set<AnyCancellable>()
    
    enum ContentType {
        
        case empty
        case banks(TopBanksViewModel)
        case placeHolder([LatestPaymentsView.ViewModel.PlaceholderViewModel])
    }
    
    init(_ model: Model, content: ContentType, phone: String) {
        
        self.model = model
        self.content = content
        self.phone = phone
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    convenience init(_ model: Model, phone: String) {
        
        let content: ContentType = .placeHolder(.init(repeating: .init(), count: 6))
        self.init(model, content: content, phone: phone)

        bind()
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.LatestPayments.BanksList.Response:
                    
                    switch payload.result {
                    case .success(let banks):

                        if let banks = Self.reduce(contact: model.contact(for: phone), banks: banks, banksData: model.bankList.value, action: { [weak self] bank in { self?.action.send(ContactsTopBanksSectionViewModelAction.TopBanksDidTapped(bank: bank)) } }) {
                            
                            self.content = .banks(banks)
                        }
                        
                    case .failure:
                        self.content = .empty
                    }
                default: break
                }
            }.store(in: &bindings)
    }
    
    static func reduce(contact: AddressBookContact?, banks: [PaymentPhoneData], banksData: [BankData], action: @escaping ((BankData) -> () -> Void)) -> TopBanksViewModel? {
        
        var banksList = [TopBanksViewModel.Bank]()
        
        for bank in banks {
            
            if let bankName = bank.bankName,
                let defaultBank = bank.defaultBank,
                let payment = bank.payment,
                let bankId = bank.bankId,
                let bankData = banksData.first(where: { $0.memberId == bankId }) {

                let contact = payment ? contact : nil
                let bankImage = bankData.svgImage.image
                
                banksList.append(.init(image: bankImage, defaultBank: defaultBank, name: contact?.fullName, bankName: bankName, action: action(bankData)))
            }
        }
        
        return .init(banks: banksList)
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
        
        let bank: BankData
    }
}
