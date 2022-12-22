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
                    
                    // на экране платежей нижний переход
                    let qrScannerModel = QRViewModel.init(closeAction: {
                        self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                    })
                    
                    self.bind(qrScannerModel)
                    self.link = .qrScanner(qrScannerModel)
                   
                case _ as PaymentsTransfersViewModelAction.Close.BottomSheet:
                    bottomSheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Sheet:
                    sheet = nil
                
                case _ as PaymentsTransfersViewModelAction.Close.Link:
                    link = nil
                    
                case _ as PaymentsTransfersViewModelAction.OpenQr:
//                    link = .qrScanner(.init(closeAction:  { [weak self] value  in
//
//                        if !value {
//                        self?.action.send(PaymentsTransfersViewModelAction
//                                          .Close.Link() )
//                    } else {
//                        let serviceOperators = OperatorsViewModel(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
//                        }, template: nil)
//                        self?.link = .serviceOperators(serviceOperators)
//                        InternetTVMainViewModel.filter = GlobalModule.UTILITIES_CODE
//                    }}))
                    
                    print()
                  
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
                            }, mode: .general))))
                            
                        case (.service, let paymentData as PaymentServiceData):
                            link = .service(.init(model: model, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData, mode: .general))
                                    
                        case (.transport, let paymentData as PaymentServiceData):
                            link = .transport(.init(model: model, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData, mode: .general))
                            
                        case (.internet, let paymentData as PaymentServiceData):
                            link = .internet(.init(model: model, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, paymentServiceData: paymentData, mode: .general))
                            
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
                        
                    case _ as PTSectionLatestPaymentsViewAction.ButtonTapped.CurrencyWallet:
                        guard let firstCurrencyWalletData = model.currencyWalletList.value.first else {
                            return
                        }
                        
                        let currency = Currency(description: firstCurrencyWalletData.code)
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: currency, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(PaymentsTransfersViewModelAction.Close.Link())}) else {
                            return
                        }

                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        
                        link = .currencyWallet(walletViewModel)
                        
                        
                    //Transfers Section
                    case let payload as PTSectionTransfersViewAction.ButtonTapped.Transfer:
                        
                        switch payload.type {
                        case .abroad:
                            link = .chooseCountry(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, mode: .general))
                            
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
                            
                            // на экране платежей нижний переход
                            let qrScannerModel = QRViewModel.init(closeAction: {
                                self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                            
                            self.bind(qrScannerModel)
                            self.link = .qrScanner(qrScannerModel)
                            
//                            if model.cameraAgent.isCameraAvailable {
//                                model.cameraAgent.requestPermissions(completion: { available in
//
//                                    if available {
//                                        if #available(iOS 14, *) {
//
//                                            // на экране платежей нижний переход
//                                            let qrScannerModel = QRViewModel.init(closeAction: {
//                                                self.action.send(PaymentsTransfersViewModelAction.Close.Link())
//                                            })
//
//                                            self.bind(qrScannerModel)
//                                            self.link = .qrScanner(qrScannerModel)
//
//                                        } else {
//                                            self.sheet = .init(type: .qrScanner(.init(closeAction: { self.action.send(PaymentsTransfersViewModelAction.Close.Link())
//                                            })))
//                                        }
//                                    } else {
//                                        self.alert = .init(
//                                            title: "Внимание",
//                                            message: "Для сканирования QR кода, необходим доступ к камере",
//                                            primary: .init(type: .cancel, title: "Понятно", action: {
//                                            }))
//                                    }
//                                })
//                            }
                            
                        case .service:
                            let serviceOperators = OperatorsViewModel(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, mode: .general)
                            link = .serviceOperators(serviceOperators)
                            InternetTVMainViewModel.filter = GlobalModule.UTILITIES_CODE
                            
                        case .internet:
                            let internetOperators = OperatorsViewModel(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, mode: .general)
                            link = .internetOperators(internetOperators)
                            InternetTVMainViewModel.filter = GlobalModule.INTERNET_TV_CODE
                            
                        case .transport:
                            let transportOperators = OperatorsViewModel(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, mode: .general)
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
    
    func bind(_ qrViewModel: QRViewModel ) {
        
        qrViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as QRViewModelAction.Result:
                    
                    switch payload.result {

                    case .qrCode(let qr):

                        guard let qrMapping = model.qrDictionary.value else { break }

                        let operatorPuref = model.dictionaryAnywayFirstOperator(with: qr, mapping: qrMapping)

                        let puref = operatorPuref?.code

                        if puref != nil {
                            
                            let operatorsViewModel = OperatorsViewModel(closeAction: {
                                self.link = nil
                            }, mode: .qr(qr))

                            self.link = .serviceOperators(operatorsViewModel)
                        } else {

                            let failedView = QRFailedViewModel(model: model)
                            self.link = .failedView(failedView)
                        }

                    case .c2bURL(let c2bURL):
                            
                        let c2bViewModel = C2BViewModel(urlString: c2bURL.absoluteString, closeAction: {
                                self.link = nil
                            })

                            self.link = .c2b(c2bViewModel)

                    case .url( _):
                        
                        let failedView = QRFailedViewModel(model: model)
                        self.link = .failedView(failedView)

                    case .unknown(let qr):

                        self.alert = .init(title: "Unknown", message: qr, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                    
                default:
                    break
                }
            }.store(in: &bindings)
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
            case anotherCard(AnotherCardViewModel)
            case qrScanner(QRViewModel)
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
        case qrScanner(QRViewModel)
        case country(CountryPaymentView.ViewModel)
        case currencyWallet(CurrencyWalletViewModel)
        case failedView(QRFailedViewModel)
        case c2b(C2BViewModel)
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
