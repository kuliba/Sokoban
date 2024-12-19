//
//  ContactsBanksPrefferedSectionViewModel.swift
//  Vortex
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
    
    init(items: [ContactsItemViewModel], phone: String?, mode: Mode, model: Model) {
        
        self.items = items
        self.phone = .init(phone)
        super.init(model: model, mode: mode)
    }
    
    convenience init(_ model: Model, phone: String?) {
        
        self.init(items: [], phone: phone, mode: .fastPayment, model: model)
        
        bind()
    }
    
    private func bind() {
        
        phone
            .combineLatest(model.paymentsByPhone)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] phoneData, banksData in
                
                if let phone = phoneData {
                    
                    if let banks = banksData[phone.digits] {
                        
                        let contact = model.contact(for: phone)
                        
                        withAnimation {
                            
                            items = Self.reduce(contact: contact, banks: banks, banksData: model.bankList.value, action: { [weak self] bank in { self?.action.send(ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped(bankId: bank.id)) } })
                        }
                    }
                    
                } else {
                    
                    withAnimation {
                        
                        items = (0..<8).map { _ in ContactsPlaceholderItemView.ViewModel(style: .bankPreffered)
                        }
                    }
                }
                
            }.store(in: &bindings)
    }
    
    static func reduce(contact: AddressBookContact?, banks: [PaymentPhoneData], banksData: [BankData], action: @escaping ((BankData) -> () -> Void)) -> [ContactsItemViewModel] {
        
        var result = [ContactsBankPrefferedItemView.ViewModel]()
        
        for bank in banks {
            
            if let bankData = banksData.first(where: { $0.memberId == bank.bankId }) {
                
                let contact = bank.payment ? contact : nil
                let bankImage = bankData.svgImage.image
                
                let item = ContactsBankPrefferedItemView.ViewModel(id: bankData.id, icon: bankImage, name: bank.bankName, isFavorite: bank.defaultBank, contactName: contact?.fullName, action: action(bankData))
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
            
            let bankId: BankData.ID
        }
    }
}
