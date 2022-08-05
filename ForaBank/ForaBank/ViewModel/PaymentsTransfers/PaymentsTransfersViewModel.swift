//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import SwiftUI
import Combine

class PaymentsTransfersViewModel: ObservableObject, Resetable {
    
    typealias TransfersSectionVM = PTSectionTransfersView.ViewModel
    typealias PaymentsSectionVM = PTSectionPaymentsView.ViewModel
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    lazy var userAccountButton: MainViewModel.UserAccountButtonViewModel = .init(
                                    logo: .ic12LogoForaColor,
                                    name: "",
                                    avatar: nil,
                                    action: { [weak self] in
                                        self?.action.send(PaymentsTransfersViewModelAction
                                                            .ButtonTapped.UserAccount())})
    
    @Published var sections: [PaymentsTransfersSectionViewModel]
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil; isTabBarHidden = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var isTabBarHidden: Bool = false
    @Published var alert: Alert.ViewModel?
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model) {
        self.navButtonsRight = []
        self.sections = [
            PTSectionLatestPaymentsView.ViewModel(model: model),
            PTSectionTransfersView.ViewModel(),
            PTSectionPaymentsView.ViewModel()
        ]
        self.model = model
        self.navButtonsRight = createNavButtonsRight()
        
        bind()
        bindSections(sections)
    }
    
    init(sections: [PaymentsTransfersSectionViewModel],
         model: Model,
         navButtonsRight: [NavigationBarButtonViewModel]) {
        
        self.sections = sections
        self.model = model
        self.navButtonsRight = navButtonsRight
    }
    
    func reset() {
        
        bottomSheet = nil
        sheet = nil
        link = nil
        isTabBarHidden = false
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsTransfersViewModelAction.ButtonTapped.UserAccount:
                    guard let clientInfo = model.clientInfo.value
                    else {return }
                    
                    link = .userAccount(
                            .init(model: model,
                                  clientInfo: clientInfo,
                                  dismissAction: {[weak self] in
                                      self?.action.send(PaymentsTransfersViewModelAction
                                                        .Close.Link() )}))
                
                case _ as PaymentsTransfersViewModelAction.ButtonTapped.Scanner:                    
                    if model.cameraAgent.isCameraAvailable {
                        model.cameraAgent.requestPermissions(completion: { available in
                            
                            if available {
                                self.link = .qrScanner(.init(closeAction: {[weak self] in
                                    self?.action.send(PaymentsTransfersViewModelAction
                                                      .Close.Link() )}))
                            } else {
                                self.alert = .init(
                                    title: "Внимание",
                                    message: "Для сканирования QR кода, необходим доступ к камере",
                                    primary: .init(type: .cancel, title: "Понятно", action: {
                                    }))
                            }
                        })
                    }
                   
                case _ as PaymentsTransfersViewModelAction.Close.BottomSheet:
                    bottomSheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Sheet:
                    sheet = nil
                
                case _ as PaymentsTransfersViewModelAction.Close.Link:
                    link = nil
                    
                case _ as PaymentsTransfersViewModelAction.OpenQr:
                    link = .qrScanner(.init(closeAction:  { [weak self] in
                        self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                    }))
                  
                case _ as PaymentsTransfersViewModelAction.ViewDidApear:
                    
                    model.action.send(ModelAction.Contacts.PermissionStatus.Request())
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientPhoto, model.clientName)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientData in
                
                userAccountButton.update(clientInfo: clientData.0,
                                         clientPhoto: clientData.1,
                                         clientName: clientData.2)
            }.store(in: &bindings)
    }
    
    private func bindSections(_ sections: [PaymentsTransfersSectionViewModel]) {
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
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })))
                        
                        case (.country, let paymentData as PaymentCountryData):
                            link = .init(.country(CountryPaymentView.ViewModel(countryData: paymentData, operatorsViewModel: .init(closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, template: nil))))
                            
                        case (.service, let paymentData as PaymentServiceData):
                            link = .service(.init(model: model, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData))
                                    
                        case (.transport, let paymentData as PaymentServiceData):
                            link = .transport(.init(model: model, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData))
                            
                        case (.internet, let paymentData as PaymentServiceData):
                            link = .internet(.init(model: model, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData))
                            
                        case (.mobile, let paymentData as PaymentServiceData):
                            link = .mobile(.init(paymentServiceData: paymentData, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }))
                            
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
                            }, template: nil))
                            
                        case .anotherCard:
                            bottomSheet = .init(type: .anotherCard(.init(closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
                            })))
                            
                        case .betweenSelf:
                            
                            bottomSheet = .init(type: .meToMe(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
                            })))
                            
                        case .byBankDetails:
                            link = .transferByRequisites(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }))
                            
                        case .byPhoneNumber:
                            sheet = .init(type: .transferByPhone(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Sheet())})))
                        }
                        
                    //Payments Section
                    case let payload as PTSectionPaymentsViewAction.ButtonTapped.Payment:
                        
                        switch payload.type {
                        case .mobile:
                            link = .mobile(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }))
                            
                        case .qrPayment:
                            if model.cameraAgent.isCameraAvailable {
                                model.cameraAgent.requestPermissions(completion: { available in
                                    
                                    if available {
                                        self.link = .qrScanner(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                        }))
                                    } else {
                                        self.alert = .init(
                                            title: "Внимание",
                                            message: "Для сканирования QR кода, необходим доступ к камере",
                                            primary: .init(type: .cancel, title: "Понятно", action: {
                                            }))
                                    }
                                })
                            }
                            
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
    
    private func createNavButtonsRight() -> [NavigationBarButtonViewModel] {
        
        [.init(icon: .ic24BarcodeScanner2,
              action: { [weak self] in
                        self?.action.send(PaymentsTransfersViewModelAction
                                            .ButtonTapped.Scanner())})
        ]
    }
}

//MARK: - Types

extension PaymentsTransfersViewModel {
    
    struct BottomSheet: BottomSheetCustomizable {

        let id = UUID()
        let type: Kind
        
        var keyboardOfssetMultiplier: CGFloat { return 0 }
        
        enum Kind {
            
            case exampleDetail(String)
            case anotherCard(AnotherCardViewModel)
            case meToMe(MeToMeViewModel)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            case meToMe(MeToMeViewModel)
            case transferByPhone(TransferByPhoneViewModel)
        }
    }
    
    enum Link {
        
        case exampleDetail(String)
        case userAccount(UserAccountViewModel)
        case mobile(MobilePayViewModel)
        case chooseCountry(OperatorsViewModel)
        case transferByRequisites(TransferByRequisitesViewModel)
        case phone(PaymentByPhoneViewModel)
        case taxAndStateService(PaymentsViewModel)
        case serviceOperators(OperatorsViewModel)
        case internetOperators(OperatorsViewModel)
        case transportOperators(OperatorsViewModel)
        case service(OperatorsViewModel)
        case internet(OperatorsViewModel)
        case transport(OperatorsViewModel)
        case template(TemplatesListViewModel)
        case qrScanner(QrViewModel)
        case country(CountryPaymentView.ViewModel)
    }
    
}


enum PaymentsTransfersViewModelAction {
    
    enum ButtonTapped {
        
        struct UserAccount: Action {}
        
        struct Scanner: Action {}
        
    }
    
    enum Close {
    
        struct BottomSheet: Action {}
        
        struct Sheet: Action {}
        
        struct Link: Action {}
    }
    
    struct OpenQr: Action {}
    
    struct ViewDidApear: Action {}
}
