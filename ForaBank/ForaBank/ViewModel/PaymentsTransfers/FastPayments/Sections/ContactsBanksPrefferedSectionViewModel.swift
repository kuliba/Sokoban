//
//  ContactsBanksPrefferedSectionViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import SwiftUI
import Combine

class ContactsBanksPrefferedSectionViewModel: ContactsSectionViewModel, ObservableObject {
    
    override var type: ContactsSectionViewModel.Kind { .banksPreferred }
    
    @Published var items: [ContactsItemViewModel]
    let phone: CurrentValueSubject<String?, Never>
    
    init(_ model: Model, items: [ContactsItemViewModel], phone: String?) {
        
        self.items = items
        self.phone = .init(phone)
        super.init(model: model)
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    convenience init(_ model: Model, phone: String?) {
        
        let placeholders = Array(repeating: ContactsPlaceholderItemView.ViewModel(style: .bankPreffered), count: 8)
        self.init(model, items: placeholders, phone: phone)

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
                        
                        if let phone = phone.value, let contact = model.contact(for: phone) {
                            
                            withAnimation {
                                
                                items = Self.reduce(contact: contact, banks: banks, banksData: model.bankList.value, action: { [weak self] bank in { self?.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bank: bank)) } })
                            }
  
                        } else {
                            
                            withAnimation {
                                
                                items = []
                            }
                        }

                    case .failure:
                        
                        withAnimation {
                            
                            items = []
                        }
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    static func reduce(contact: AddressBookContact?, banks: [PaymentPhoneData], banksData: [BankData], action: @escaping ((BankData) -> () -> Void)) -> [ContactsItemViewModel] {
        
        var result = [ContactsBankPrefferedItemView.ViewModel]()
        
        for bank in banks {
            
            if let bankName = bank.bankName,
               let defaultBank = bank.defaultBank,
               let payment = bank.payment,
               let bankId = bank.bankId,
               let bankData = banksData.first(where: { $0.memberId == bankId }) {
                
                let contact = payment ? contact : nil
                let bankImage = bankData.svgImage.image
                
                let item = ContactsBankPrefferedItemView.ViewModel(id: bankData.id, icon: bankImage, name: bankName, isFavorite: defaultBank, contactName: contact?.fullName, action: action(bankData))
                result.append(item)
            }
        }
        
        return result
    }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum BanksPreffered {
    
        struct ItemDidTapped: Action {
            
            let bank: BankData
        }
    }
}
