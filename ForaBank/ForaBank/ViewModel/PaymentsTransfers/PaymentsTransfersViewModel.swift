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
    typealias PaymentsSectionVM = PTSectionPaymentsView.ViewModel
    
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
            PTSectionPaymentsView.ViewModel()
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
                            sheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                        
                        case (.country, let paymentData as PaymentCountryData):
                            sheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                            
                        case (.service, let paymentData as PaymentServiceData):
                            sheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                                    
                        case (.transport, let paymentData as PaymentServiceData):
                            sheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                            
                        case (.internet, let paymentData as PaymentServiceData):
                            sheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                            
                        case (.mobile, let paymentData as PaymentServiceData):
                            sheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                            
                        case (.taxAndStateService, let paymentData as PaymentServiceData):
                            sheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                            
                        default: //error matching
                            sheet = .init(type: .exampleDetail(payload.latestPayment.type.rawValue)) //TODO:
                        }
                    
                    //LatestPayment Section TemplateButton
                    case _ as PTSectionLatestPaymentsViewAction.ButtonTapped.Templates:
                        sheet = .init(type: .exampleDetail("Шаблоны")) //TODO:
                        
                    //Transfers Section
                    case let payload as PTSectionTransfersViewAction.ButtonTapped.Transfer:
                        switch TransfersSectionVM.TransfersButtonType(rawValue: payload.type) {
                        case .abroad: link = .chooseCountry //TODO:
                        case .anotherCard: sheet = .init(type: .exampleDetail(payload.type))  //TODO:
                        case .betweenSelf: sheet = .init(type: .exampleDetail(payload.type))   //TODO:
                        case .byBankDetails: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .byPhoneNumber: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        
                        default: break
                        }
                        
                    //Payments Section
                    case let payload as PTSectionPaymentsViewAction.ButtonTapped.Payment:
                        switch PaymentsSectionVM.PaymentsType(rawValue: payload.type) {
                        case .qrPayment: link = .chooseCountry //TODO: 
                        case .mobile: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .service: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .internet: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .transport: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .taxAndStateService: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .socialAndGame: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .security: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
                        case .others: sheet = .init(type: .exampleDetail(payload.type)) //TODO:
        
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
            
            case exampleDetail(String)

        }
    }
    
    enum Link {
        
        case chooseCountry
    }
    
}
