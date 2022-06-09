//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import SwiftUI
import Combine

class PaymentsTransfersViewModel: ObservableObject {
    typealias TransfersSectionVM = PTSectionTransfersView.ViewModel
    
    @Published var sections: [PaymentsTransfersSectionViewModel]
    
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model) {
        self.sections = [
            PTSectionLatestPaymentsView.ViewModel(model: model),
            PTSectionTransfersView.ViewModel(),
            PTSectionPayGroupView.ViewModel()
        ]
        self.model = model
        bindSections(sections)
    }
    
    init(sections: [PaymentsTransfersSectionViewModel], model: Model) {
        self.sections = sections
        self.model = model
    }
    
    func bindSections(_ sections: [PaymentsTransfersSectionViewModel]) {
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    
                    //LatestPayments Section Buttons
                    case let payload as PTSectionLatestPaymentsViewAction.ButtonTapped.LatestPayment:
                        
                        switch (payload.latestPayment.type, payload.latestPayment) {
                        case (.phone, let paymentData as PaymentGeneralData):
                            break //TODO:
                        
                        case (.country, let paymentData as PaymentCountryData):
                            break //TODO:
                            
                        case (.service, let paymentData as PaymentServiceData):
                            break //TODO:
                                    
                        case (.transport, let paymentData as PaymentServiceData):
                            break //TODO:
                            
                        case (.internet, let paymentData as PaymentServiceData):
                            break //TODO:
                            
                        case (.mobile, let paymentData as PaymentServiceData):
                            break //TODO:
                            
                        case (.taxAndStateService, let paymentData as PaymentServiceData):
                            break //TODO:
                            
                        default: //error matching
                            break //TODO:
                        }
                    
                    //LatestPayment Section TemplateButton
                    case _ as PTSectionLatestPaymentsViewAction.ButtonTapped.Templates:
                        link = .chooseCountry
                        
                    //Transfers Section
                    case let payload as PTSectionTransfersViewAction.ButtonTapped.Transfer:
                        switch TransfersSectionVM.TransfersButtonType(rawValue: payload.type) {
                        case .abroad: link = .chooseCountry
                        case .anotherCard: sheet = .init(type: .country)
                        case .betweenSelf: break
                        case .byBankDetails: break
                        case .byPhoneNumber: break
                        
                        default: break
                            
                        }
                    
                    default:
                        break

                    }
                    
                }.store(in: &bindings)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case country
            case productProfile(ProductProfileViewModel)
            case userAccount(UserAccountViewModel)
            case messages(MessagesHistoryViewModel)
            case myProducts(MyProductsViewModel)
            case places(PlacesViewModel)
        }
    }
    
    enum Link {
        
        case chooseCountry
    }
    
}

enum PaymentsTransfersViewModelAction {

    struct OpenChooseCountry: Action {}
    
    struct OpenCountryPayment: Action {}
    
}
