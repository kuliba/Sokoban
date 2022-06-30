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
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var sections: [PaymentsTransfersSectionViewModel]
    
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil; isTabBarHidden = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var isTabBarHidden: Bool = false
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model) {
        self.sections = [
            PTSectionLatestPaymentsView.ViewModel(model: model),
            PTSectionTransfersView.ViewModel(),
            PTSectionPaymentsView.ViewModel()
        ]
        self.model = model
        bind()
        bindSections(sections)
    }
    
    init(sections: [PaymentsTransfersSectionViewModel], model: Model) {
        self.sections = sections
        self.model = model
    }
    
    func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsTransfersViewModelAction.Close.BottomSheet:
                    bottomSheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Sheet:
                    sheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Link:
                    link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
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
                            link = .init(.phone(PaymentByPhoneViewModel(phoneNumber: paymentData.phoneNumber, bankId: paymentData.bankId, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })))
                        
                        case (.country, let paymentData as PaymentCountryData):
                            bottomSheet = .init(type: .country(paymentData))
                            
                        case (.service, let paymentData as PaymentServiceData):
                            link = .service(.init(model: model, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData))
                                    
                        case (.transport, let paymentData as PaymentServiceData):
                            link = .transport(.init(model: model, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData))
                            
                        case (.internet, let paymentData as PaymentServiceData):
                            link = .internet(.init(model: model, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData))
                            
                        case (.mobile, let paymentData as PaymentServiceData):
                            link = .mobile(.init(paymentServiceData: paymentData))
                            
                        case (.taxAndStateService, let paymentData as PaymentServiceData):
                            bottomSheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
                            
                        default: //error matching
                            bottomSheet = .init(type: .exampleDetail(payload.latestPayment.type.rawValue)) //TODO:
                        }
                    
                    //LatestPayment Section TemplateButton
                    case _ as PTSectionLatestPaymentsViewAction.ButtonTapped.Templates:
                        let viewModel = TemplatesListViewModel(model, dismissAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                        })
                        link = .template(viewModel)
                        
                    //Transfers Section
                    case let payload as PTSectionTransfersViewAction.ButtonTapped.Transfer:
                        
                        switch payload.type {
                        case .abroad:
                            link = .chooseCountry(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }))
                            
                        case .anotherCard:
                            bottomSheet = .init(type: .anotherCard(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
                            })))
                            
                        case .betweenSelf:
                            
                            bottomSheet = .init(type: .meToMe(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
                            }, paymentTemplate: nil)))
                            
                        case .byBankDetails:
                            link = .transferByRequisites(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentTemplate: nil))
                            
                        case .byPhoneNumber:
                            sheet = .init(type: .transferByPhone(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
                            })))
                        }
                        
                    //Payments Section
                    case let payload as PTSectionPaymentsViewAction.ButtonTapped.Payment:
                        
                        switch payload.type {
                        case .mobile:
                            link = .mobile(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }))
                            
                        case .qrPayment:
                            bottomSheet = .init(type: .exampleDetail(payload.type.rawValue)) 

                        case .service:
                            let serviceOperators = OperatorsViewModel(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, template: nil)
                            link = .serviceOperators(serviceOperators)
                            InternetTVMainViewModel.filter = GlobalModule.UTILITIES_CODE
                            
                        case .internet:
                            let internetOperators = OperatorsViewModel(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, template: nil)
                            link = .internetOperators(internetOperators)
                            InternetTVMainViewModel.filter = GlobalModule.INTERNET_TV_CODE
                            
                        case .transport:
                            let transportOperators = OperatorsViewModel(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, template: nil)
                            link = .transportOperators(transportOperators)
                            InternetTVMainViewModel.filter = GlobalModule.PAYMENT_TRANSPORT
                       
                        case .taxAndStateService:
                            let taxAndStateServiceVM = PaymentsViewModel(model, category: Payments.Category.taxes)
                            taxAndStateServiceVM.closeAction = { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }
                            link = .init(.taxAndStateService(taxAndStateServiceVM))
                            
                        case .socialAndGame: bottomSheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
                        case .security: bottomSheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
                        case .others: bottomSheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
        
                        }
                    default:
                        break

                    }
                    
                }.store(in: &bindings)
        }
    }
    
    struct BottomSheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case exampleDetail(String)
            case anotherCard(AnotherCardViewModel)
            case country(PaymentCountryData)
            case meToMe(MeToMeViewModel)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case transferByPhone(TransferByPhoneViewModel)
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
        case service(OperatorsViewModel)
        case internet(InternetTVDetailsViewModel)
        case transport(AvtodorDetailsViewModel)
        case template(TemplatesListViewModel)
    }
}

enum PaymentsTransfersViewModelAction {
    
    enum Close {
    
        struct BottomSheet: Action {}
        
        struct Sheet: Action {}
        
        struct Link: Action {}
    }
}
