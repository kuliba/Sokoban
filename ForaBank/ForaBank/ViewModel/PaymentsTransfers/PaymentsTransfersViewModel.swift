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
                            link = .init(.phone(PaymentByPhoneViewModel(phoneNumber: paymentData.phoneNumber, bankId: paymentData.bankId, closeAction: { [weak self] in
                                self?.link = nil
                            })))
                        
                        case (.country, let paymentData as PaymentCountryData):
                            sheet = .init(type: .country(paymentData))
                            
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
                    case let payload as PTSectionLatestPaymentsViewAction.ButtonTapped.Templates:
                        sheet = .init(type: .template(payload.viewModel))
                        
                    //Transfers Section
                    case let payload as PTSectionTransfersViewAction.ButtonTapped.Transfer:
                        
                        switch payload.type {
                        case .abroad:
                            link = .chooseCountry(.init(closeAction: { [weak self] in
                                self?.link = nil
                            }))
                            
                        case .anotherCard:
                            sheet = .init(type: .anotherCard(.init(closeAction: { [weak self] in
                                self?.sheet = nil
                            })))
                            
                        case .betweenSelf:
                            
                            sheet = .init(type: .meToMe(.init(closeAction: { [weak self] in
                                self?.sheet = nil
                            })))
                            
                        case .byBankDetails:
                            link = .transferByRequisites(.init(closeAction: { [weak self] in
                                self?.link = nil
                            }))
                        case .byPhoneNumber:
                            sheet = .init(type: .transferByPhone(.init(closeAction: { [weak self] in
                                self?.sheet = nil
                            })))
                        }
                        
                    //Payments Section
                    case let payload as PTSectionPaymentsViewAction.ButtonTapped.Payment:
                        switch payload.type {
                        case .mobile:
                            link = .mobile(.init(closeAction: {
                                self.link = nil
                            }))
                        case .qrPayment: link = .exampleDetail(payload.type.rawValue) //TODO:
                        case .service:
                            let serviceOperators = OperatorsViewModel(closeAction: {self.link = nil})
                            link = .serviceOperators(serviceOperators)
                            InternetTVMainViewModel.filter = GlobalModule.UTILITIES_CODE
                        case .internet:
                            let internetOperators = OperatorsViewModel(closeAction: {self.link = nil})
                            link = .internetOperators(internetOperators)
                            InternetTVMainViewModel.filter = GlobalModule.INTERNET_TV_CODE
                        case .transport:
                            let transportOperators = OperatorsViewModel(closeAction: {self.link = nil})
                            link = .transportOperators(transportOperators)
                            InternetTVMainViewModel.filter = GlobalModule.PAYMENT_TRANSPORT
                       
                        case .taxAndStateService:
                            let taxAndStateServiceVM = PaymentsViewModel(model, category: Payments.Category.taxes)
                            taxAndStateServiceVM.closeAction = { [weak self] in self?.link = nil }
                            link = .init(.taxAndStateService(taxAndStateServiceVM))
                            
                        case .socialAndGame: sheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
                        case .security: sheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
                        case .others: sheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
        
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
            case anotherCard(AnotherCardViewModel)
            case country(PaymentCountryData)
            case meToMe(MeToMeViewModel)
            case transferByPhone(TransferByPhoneViewModel)
            case template(TemplatesListViewModel)
        }
    }
    
    enum Link {
        
        case exampleDetail(String)
        case mobile(MobilePayViewModel)
        case chooseCountry(ChooseCountryViewModel)
        case transferByRequisites(TransferByRequisitesViewModel)
        case phone(PaymentByPhoneViewModel)
        case taxAndStateService(PaymentsViewModel)
        case serviceOperators(OperatorsViewModel)
        case internetOperators(OperatorsViewModel)
        case transportOperators(OperatorsViewModel)
    }
}
