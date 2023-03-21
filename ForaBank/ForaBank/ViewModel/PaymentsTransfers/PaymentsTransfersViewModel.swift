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
    @Published var fullCover: FullCover?
    @Published var link: Link? { didSet { isLinkActive = link != nil; isTabBarHidden = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var isTabBarHidden: Bool = false
    @Published var fullScreenSheet: FullScreenSheet?
    @Published var alert: Alert.ViewModel?
    private let model: Model
    
    var rootActions: RootViewModel.RootActions?
    
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
        fullCover = nil
        sheet = nil
        link = nil
        fullScreenSheet = nil
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
                    
                    // на экране платежей верхний переход
                    let qrScannerModel = QRViewModel.init(closeAction: {
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                    })
                    
                    self.bind(qrScannerModel)
                    fullScreenSheet = .init(type: .qrScanner(qrScannerModel))
                    
                case _ as PaymentsTransfersViewModelAction.Close.BottomSheet:
                    bottomSheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Sheet:
                    sheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.FullCover:
                    fullCover = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Link:
                    link = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.FullScreenSheet:
                    fullScreenSheet = nil
                    
                    
                case _ as PaymentsTransfersViewModelAction.Close.DismissAll:
                    
                    withAnimation {
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                    }
                    
                    
                case _ as PaymentsTransfersViewModelAction.ViewDidApear:
                    model.action.send(ModelAction.Contacts.PermissionStatus.Request())
                    isTabBarHidden = false
                
                case let payload as PaymentsTransfersViewModelAction.Show.Requisites:
                    
                    Task.detached(priority: .high) { [self] in
                        
                        do {
                            
                            let operationViewModel = try await PaymentsViewModel(source: .requisites(qrCode: payload.qrCode), model: model, closeAction: {})
                            bind(operationViewModel)
                            self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                
                                self.link = .transferByRequisites(operationViewModel)
                            }
                        } catch {
                            
                            self.link = nil
                            LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for transfer by requisites category with error: \(error.localizedDescription) ")
                        }
                    }
                    
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
                    case let payload as LatestPaymentsViewModelAction.ButtonTapped.LatestPayment:
                        handle(latestPayment: payload.latestPayment)
                        
                        //LatestPayment Section TemplateButton
                    case _ as LatestPaymentsViewModelAction.ButtonTapped.Templates:
                        let viewModel = TemplatesListViewModel(model, dismissAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                        })
                        link = .template(viewModel)
                        
                    case _ as LatestPaymentsViewModelAction.ButtonTapped.CurrencyWallet:
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
                            
                            let operatorsViewModel = OperatorsViewModel(mode: .general, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                            link = .chooseCountry(operatorsViewModel)
                            
                        case .anotherCard:
                            bottomSheet = .init(type: .anotherCard(.init(closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
                            })))
                            
                        case .betweenSelf:
                            
                            guard let viewModel = PaymentsMeToMeViewModel(model, mode: .demandDeposit) else {
                                return
                            }
                            
                            let swapViewModel = viewModel.swapViewModel
                            bind(viewModel, swapViewModel: swapViewModel)
                            
                            bottomSheet = .init(type: .meToMe(viewModel))
                            
                        case .requisites:
                            
                            Task.detached(priority: .high) { [self] in
                                
                                do {
                                    
                                    let paymentsViewModel = try await PaymentsViewModel(model, service: .requisites, closeAction: { [weak self] in
                                        self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                    })
                                    
                                    bind(paymentsViewModel)
                                    await MainActor.run {
                                        
                                        link = .init(.transferByRequisites(paymentsViewModel))
                                    }
                                    
                                } catch {
                                    
                                    //TODO: show alert?
                                    LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for transfer by requisites category with error: \(error.localizedDescription) ")
                                }
                            }
                            
                        case .byPhoneNumber:
                            openContacts()
                        }
                        
                        //Payments Section
                    case let payload as PTSectionPaymentsViewAction.ButtonTapped.Payment:
                        
                        switch payload.type {
                        case .mobile:
                            link = .mobile(.init(closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }))
                            
                        case .qrPayment:
                            
                            // на экране платежей нижний переход
                            let qrScannerModel = QRViewModel(closeAction: {
                                self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                            })
                            
                            self.bind(qrScannerModel)
                            fullScreenSheet = .init(type: .qrScanner(qrScannerModel))
                            
                        case .service:
                            let serviceOperators = OperatorsViewModel(mode: .general, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, requisitsViewAction: { [weak self] in
                                
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [self] in
                                    
                                    Task.detached(priority: .medium) { [self] in
                                        
                                        do {
                                            
                                            guard let model = self?.model else {
                                                return
                                            }
                                            
                                            let paymentsViewModel = try await PaymentsViewModel(model, service: .requisites, closeAction: {
                                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                            })
                                            
                                            await MainActor.run {
                                                
                                                self?.link = .init(.payments(paymentsViewModel))
                                            }
                                            
                                        } catch {
                                            
                                            await MainActor.run {
                                                
                                                self?.alert = .init(title: "Error", message: "Unable create PaymentsViewModel for Requisits with error: \(error.localizedDescription)", primary: .init(type: .cancel, title: "Ok", action: {}))
                                            }
                                            
                                            LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for Requisits: with error: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }, qrAction: { [weak self] in
                                
                                self?.link = nil
                                self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
                                
                            })
                            
                            link = .serviceOperators(serviceOperators)
                            InternetTVMainViewModel.filter = GlobalModule.UTILITIES_CODE
                            
                        case .internet:
                            let internetOperators = OperatorsViewModel(mode: .general, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, requisitsViewAction: { [weak self] in
                                
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [self] in
                                    
                                    Task.detached(priority: .medium) { [self] in
                                        
                                        do {
                                            
                                            guard let model = self?.model else {
                                                return
                                            }
                                            
                                            let paymentsViewModel = try await PaymentsViewModel(model, service: .requisites, closeAction: {
                                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                            })
                                            
                                            self?.bind(paymentsViewModel)
                                            
                                            await MainActor.run {
                                                
                                                self?.link = .init(.payments(paymentsViewModel))
                                            }
                                            
                                        } catch {
                                            
                                            await MainActor.run {
                                                
                                                self?.alert = .init(title: "Error", message: "Unable create PaymentsViewModel for Requisits with error: \(error.localizedDescription)", primary: .init(type: .cancel, title: "Ok", action: {}))
                                            }
                                            
                                            LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for Requisits: with error: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }, qrAction: { [weak self] in
                                
                                self?.link = nil
                                self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
                                
                            })
                            link = .internetOperators(internetOperators)
                            InternetTVMainViewModel.filter = GlobalModule.INTERNET_TV_CODE
                            
                        case .transport:
                            let transportOperators = OperatorsViewModel(mode: .general, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, requisitsViewAction: { [weak self] in
                                
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) { [self] in
                                    
                                    Task.detached(priority: .medium) { [self] in
                                        
                                        do {
                                            
                                            guard let model = self?.model else {
                                                return
                                            }
                                            
                                            let paymentsViewModel = try await PaymentsViewModel(model, service: .requisites, closeAction: {
                                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                            })
                                            
                                            self?.bind(paymentsViewModel)
                                            await MainActor.run {
                                                
                                                self?.link = .init(.payments(paymentsViewModel))
                                            }
                                            
                                        } catch {
                                            
                                            await MainActor.run {
                                                
                                                self?.alert = .init(title: "Error", message: "Unable create PaymentsViewModel for Requisits with error: \(error.localizedDescription)", primary: .init(type: .cancel, title: "Ok", action: {}))
                                            }
                                            
                                            LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for Requisits: with error: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }, qrAction: { [weak self] in
                                
                                self?.link = nil
                                self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
                                
                            })
                            link = .transportOperators(transportOperators)
                            InternetTVMainViewModel.filter = GlobalModule.PAYMENT_TRANSPORT
                            
                        case .taxAndStateService:
                            
                            self.alert = .init(title: "Сервис временно не доступен", message: "Приносим извинения за доставленные неудобства", primary: .init(type: .default, title: "Ок", action: {}))
                            
                            //MARK: uncommited after debugging tax service
                            /*
                             Task.detached(priority: .high) { [self] in
                             
                             do {
                             let paymentsViewModel = try await PaymentsViewModel(category: Payments.Category.taxes, model: model) { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                             }
                             
                             await MainActor.run {
                             
                             link = .init(.payments(paymentsViewModel))
                             }
                             
                             } catch {
                             
                             //TODO: show alert?
                             LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for  taxes category with error: \(error.localizedDescription) ")
                             }
                             }
                             */
                            
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
    
    private func bind(_ paymentsViewModel: PaymentsViewModel) {
    
        paymentsViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
            
                switch action {
                
                case _ as PaymentsViewModelAction.ScanQrCode:
                    
                    self.link = nil
                    
                    let qrScannerModel = QRViewModel.init(closeAction: {
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                    })
                    
                    self.bind(qrScannerModel)
                    fullScreenSheet = .init(type: .qrScanner(qrScannerModel))
                    
                default: break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ viewModel: PaymentsMeToMeViewModel, swapViewModel: ProductsSwapView.ViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsMeToMeAction.Response.Success:
                    
                    guard let productIdFrom = swapViewModel.productIdFrom,
                          let productIdTo = swapViewModel.productIdTo else {
                        return
                    }
                    
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdFrom))
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdTo))
                    
                    bind(payload.viewModel)
                    fullCover = .init(type: .successMeToMe(payload.viewModel))
                    
                case _ as PaymentsMeToMeAction.Response.Failed:
                    
                    makeAlert("Перевод выполнен")
                    self.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
               
                case _ as PaymentsMeToMeAction.Close.BottomSheet:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())

                case let payload as PaymentsMeToMeAction.InteractionEnabled:
                    
                    guard let bottomSheet = bottomSheet else {
                        return
                    }
                    
                    bottomSheet.isUserInteractionEnabled.value = payload.isUserInteractionEnabled
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ viewModel: PaymentsSuccessViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsSuccessAction.Button.Close:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.FullCover())
                    self.action.send(PaymentsTransfersViewModelAction.Close.DismissAll())
                    
                    self.rootActions?.switchTab(.main)
                    
                case _ as PaymentsSuccessAction.Button.Repeat:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.FullCover())
                    self.rootActions?.switchTab(.payments)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ viewModel: ContactsViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ContactsViewModelAction.PaymentRequested:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.Sheet())
                    
                    switch payload.source {
                    case let .direct(phone: phone, bankId: bankId, countryId: countryId):
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [self] in
                            
                            guard let country = self.model.countriesList.value.first(where: { $0.id == countryId }),
                                  let bank = self.model.bankList.value.first(where: { $0.id == bankId }) else {
                                return
                            }
                            self.link = .init(.country(.init(phone: phone, country: country, bank: bank, operatorsViewModel: .init(mode: .general, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }))))
                        }
                        
                    case let .abroad(phone: phone, countryId: countryId):
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                            
                            guard let country = self.model.countriesList.value.first(where: { $0.id == countryId }) else {
                                return
                            }
                            self.link = .init(.country(.init(phone: phone, country: country, bank: nil, operatorsViewModel: .init(mode: .general, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, requisitsViewAction: {}, qrAction: { [weak self] in
                                
                                self?.link = nil
                                self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
                                
                            }))))
                        }
                        
                    case let .latestPayment(latestPaymentId):
                        guard let latestPayment = model.latestPayments.value.first(where: { $0.id == latestPaymentId }) else {
                            return
                        }
                        handle(latestPayment: latestPayment)
                        
                    default:
                        
                        Task {
                            
                            do {
                                
                                let paymentsViewModel = try await PaymentsViewModel(source: payload.source, model: model) { [weak self] in
                                    self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
                                        
                                        self?.openContacts()
                                    }
                                }
                                
                                await MainActor.run {
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                        
                                        self.link = .init(.payments(paymentsViewModel))
                                    }
                                }
                                
                            } catch {
                                
                                await MainActor.run {
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                        
                                        self.alert = .init(title: "Error", message: "Unable create PaymentsViewModel for source: \(payload.source) with error: \(error.localizedDescription)", primary: .init(type: .cancel, title: "Ok", action: {}))
                                    }
                                }
                                
                                LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for source: \(payload.source) with error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(_ qrViewModel: QRViewModel ) {
        
        qrViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as QRViewModelAction.Result:
                    
                    switch payload.result {
                    case .qrCode(let qr):
                        
                        if let qrMapping = model.qrMapping.value {
                            
                            if let operators = model.dictionaryAnywayOperators(with: qr, mapping: qrMapping)  {
                                
                                guard operators.count > 0 else {
                                
                                    self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                    self.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))
                                    return
                                }
                                
                                if operators.count == 1 {
                                    
                                    self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) { [self] in
                                        
                                        let viewModel = InternetTVDetailsViewModel(model: model, qrCode: qr, mapping: qrMapping)
                                        
                                        self.link = .operatorView(viewModel)
                                    }
                                    
                                } else {
                                    
                                    self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                        
                                        let navigationBarViewModel = NavigationBarView.ViewModel(title: "Все регионы", titleButton: .init(icon: Image.ic24ChevronDown, action: { [weak self] in
                                            self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                                        }), leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: { [weak self] in self?.link = nil })])
                                        
                                        let operatorsViewModel = QRSearchOperatorViewModel(searchBar: .init(textFieldPhoneNumberView: .init(style: .general, placeHolder: .text("Название или ИНН")), state: .idle, icon: Image.ic24Search),
                                                                                           navigationBar: navigationBarViewModel, model: self.model,
                                                                                           operators: operators, addCompanyAction: { [weak self] in
                                            
                                            self?.link = nil
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                self?.rootActions?.switchTab(.chat)
                                            }
                                            
                                        }, requisitesAction: { [weak self] in
                                            
                                            self?.link = nil
                                            self?.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))


                                        }, qrCode: qr)
                                        
                                        self.link = .searchOperators(operatorsViewModel)
                                    }
                                }
                                
                            } else {
                                
                                self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                self.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))
                            }
                            
                        } else {
                            
                            self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                
                                let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                    
                                    self?.link = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                        self?.rootActions?.switchTab(.chat)
                                    }
                                    
                                }, requisitsAction: { [weak self] in
                                    
                                    self?.fullScreenSheet = nil
                                    self?.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))

                                })
                                self.link = .failedView(failedView)
                            }
                        }
                        
                    case .c2bURL(let c2bURL):
                        
                        // show c2b payment after delay required to finish qr scanner close animation
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let c2bViewModel = C2BViewModel(urlString: c2bURL.absoluteString, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                            
                            self.link = .c2b(c2bViewModel)
                        }
                        
                    case .c2bSubscribeURL(let url):
                        
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        Task.detached(priority: .high) { [self] in
                            
                            do {
                                
                                let operationViewModel = try await PaymentsViewModel(source: .c2bSubscribe(url), model: model, closeAction: {})
                                bind(operationViewModel)
                                
                                await MainActor.run {
                                    
                                    self.link = .payments(operationViewModel)
                                }
                                
                            } catch {
                                
                                await MainActor.run {
                                    
                                    self.alert = .init(title: "Ошибка привязки счета", message: error.localizedDescription, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.alert = nil }))
                                }
                                
                                LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for c2b subscribtion with error: \(error.localizedDescription) ")
                            }
                        }
                        
                    case .url(_):
                        
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                
                                self?.link = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                    self?.rootActions?.switchTab(.chat)
                                }
                                
                            }, requisitsAction: { [weak self] in
                                
                                self?.fullScreenSheet = nil
                                Task.detached(priority: .high) { [self] in
                                    
                                    do {
                                        guard let model = self?.model else {
                                            return
                                        }
                                        
                                        let paymentsViewModel = try await PaymentsViewModel(model, service: .requisites, closeAction: { [weak self] in
                                            self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                        })
                                        
                                        self?.bind(paymentsViewModel)
                                        await MainActor.run {
                                            
                                            self?.link = .init(.transferByRequisites(paymentsViewModel))
                                        }
                                        
                                    } catch {
                                        
                                        //TODO: show alert?
                                        LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for transfer by requisites category with error: \(error.localizedDescription) ")
                                    }
                                }

                            })
                            self.link = .failedView(failedView)
                        }
                        
                    case .unknown:
                        
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                
                                self?.link = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                    self?.rootActions?.switchTab(.chat)
                                }
                                
                            }, requisitsAction: { [weak self] in
                                
                                self?.fullScreenSheet = nil
                                Task.detached(priority: .high) { [self] in
                                    
                                    do {
                                        
                                        guard let model = self?.model else {
                                            return
                                        }
                                        
                                        let paymentsViewModel = try await PaymentsViewModel(model, service: .requisites, closeAction: { [weak self] in
                                            self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                        })
                                        
                                        self?.bind(paymentsViewModel)
                                        await MainActor.run {
                                            
                                            self?.link = .init(.transferByRequisites(paymentsViewModel))
                                        }
                                        
                                    } catch {
                                        
                                        //TODO: show alert?
                                        LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for transfer by requisites category with error: \(error.localizedDescription) ")
                                    }
                                }

                            })
                            self.link = .failedView(failedView)
                        }
                    }
                    
                    
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    private func makeAlert(_ message: String) {
        
        let alertViewModel = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "ОК") { [weak self] in
            self?.action.send(ProductProfileViewModelAction.Close.Alert())
        })
        
        alert = .init(alertViewModel)
    }
    
    private func createNavButtonsRight() -> [NavigationBarButtonViewModel] {
        
        [.init(icon: .ic24BarcodeScanner2,
               action: { [weak self] in
            self?.action.send(PaymentsTransfersViewModelAction
                .ButtonTapped.Scanner())})
        ]
    }
}

//MARK: - Helpers

extension PaymentsTransfersViewModel {
    
    func handle(latestPayment: LatestPaymentData) {
        
        switch (latestPayment.type, latestPayment) {
        case (.phone, let paymentData as PaymentGeneralData):
            
            Task {
                
                do {
                    
                    let paymentsViewModel = try await PaymentsViewModel(source: .sfp(phone: paymentData.phoneNumber, bankId: paymentData.bankId), model: model) { [weak self] in
                        
                        self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
                            
                            self?.openContacts()
                        }
                    }
                    
                    await MainActor.run {
                        
                        self.link = .init(.payments(paymentsViewModel))
                    }
                    
                } catch {
                    
                    await MainActor.run {
                        
                        self.alert = .init(title: "Error", message: "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения.", primary: .init(type: .cancel, title: "Ok", action: {}))
                    }
                    
                    LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for SFP source with phone: \(paymentData.phoneNumber) and bankId: \(paymentData.bankId)  with error: \(error.localizedDescription)")
                }
            }
            
        case (.country, let paymentData as PaymentCountryData):
            let operatorsViewModel = OperatorsViewModel(mode: .general, closeAction: { [weak self] in
                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
            })
            link = .init(.country(CountryPaymentView.ViewModel(countryData: paymentData, operatorsViewModel: operatorsViewModel)))
            
        case (.service, let paymentData as PaymentServiceData):
            let operatorsViewModel = OperatorsViewModel(mode: .general, paymentServiceData: paymentData, model: model, closeAction: { [weak self] in
                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }, requisitsViewAction: {}, qrAction: { [weak self] in
                
                self?.link = nil
            })
            link = .service(operatorsViewModel)
            
        case (.transport, let paymentData as PaymentServiceData):
            let operatorsViewModel = OperatorsViewModel(mode: .general, paymentServiceData: paymentData, model: model, closeAction: { [weak self] in
                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }, requisitsViewAction: {}, qrAction: { [weak self] in
                
                self?.link = nil
            })
            link = .transport(operatorsViewModel)
            
        case (.internet, let paymentData as PaymentServiceData):
            let operatorsViewModel = OperatorsViewModel(mode: .general, paymentServiceData: paymentData, model: model, closeAction: { [weak self] in
                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }, requisitsViewAction: {}, qrAction: { [weak self] in
                
                self?.link = nil
            })
            link = .internet(operatorsViewModel)
            
        case (.mobile, let paymentData as PaymentServiceData):
            link = .mobile(.init(paymentServiceData: paymentData, closeAction: { [weak self] in
                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }))
            
        case (.taxAndStateService, let paymentData as PaymentServiceData):
            bottomSheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
            
        default: //error matching
            bottomSheet = .init(type: .exampleDetail(latestPayment.type.rawValue)) //TODO:
        }
    }
    
    func openContacts() {
        
        let contactsViewModel = ContactsViewModel(model, mode: .fastPayments(.contacts))
        sheet = .init(type: .fastPayment(contactsViewModel))
        bind(contactsViewModel)
    }
}

//MARK: - Types

extension PaymentsTransfersViewModel {
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let type: Kind
        
        let isUserInteractionEnabled: CurrentValueSubject<Bool, Never> = .init(true)
        
        var keyboardOfssetMultiplier: CGFloat {
            
            switch type {
            case .meToMe: return 1
            default: return 0
            }
        }
        
        var animationSpeed: Double {
            
            switch type {
            case .meToMe: return 0.4
            default: return 0.5
            }
        }
        
        enum Kind {
            
            case exampleDetail(String)
            case anotherCard(AnotherCardViewModel)
            case meToMe(PaymentsMeToMeViewModel)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case meToMe(PaymentsMeToMeViewModel)
            case successMeToMe(PaymentsSuccessViewModel)
            case transferByPhone(TransferByPhoneViewModel)
            case anotherCard(AnotherCardViewModel)
            case fastPayment(ContactsViewModel)
        }
    }
    
    struct FullCover: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            case successMeToMe(PaymentsSuccessViewModel)
        }
    }
    
    enum Link {
        
        case exampleDetail(String)
        case userAccount(UserAccountViewModel)
        case mobile(MobilePayViewModel)
        case chooseCountry(OperatorsViewModel)
        case transferByRequisites(PaymentsViewModel)
        case phone(PaymentByPhoneViewModel)
        case payments(PaymentsViewModel)
        case serviceOperators(OperatorsViewModel)
        case internetOperators(OperatorsViewModel)
        case transportOperators(OperatorsViewModel)
        case service(OperatorsViewModel)
        case internet(OperatorsViewModel)
        case transport(OperatorsViewModel)
        case template(TemplatesListViewModel)
        case country(CountryPaymentView.ViewModel)
        case currencyWallet(CurrencyWalletViewModel)
        case failedView(QRFailedViewModel)
        case c2b(C2BViewModel)
        case searchOperators(QRSearchOperatorViewModel)
        case operatorView(InternetTVDetailsViewModel)
    }
    
    struct FullScreenSheet: Identifiable, Equatable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case qrScanner(QRViewModel)
        }
        
        static func == (lhs: PaymentsTransfersViewModel.FullScreenSheet, rhs: PaymentsTransfersViewModel.FullScreenSheet) -> Bool {
            lhs.id == rhs.id
        }
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
        
        struct FullCover: Action {}
        
        struct Link: Action {}
        
        struct DismissAll: Action {}
        
        struct FullScreenSheet: Action {}
    }
    
    struct OpenQr: Action {}
    
    enum Show {
        
        struct Requisites: Action {
            
            let qrCode: QRCode
        }
    }
    
    struct ViewDidApear: Action {}
}
