//
//  RootViewModelFactory+getRootNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine
import FlowCore
import SavingsAccount
import RemoteServices
import PDFKit
import ProductSelectComponent

extension RootViewModelFactory {
    
    typealias MakeProductProfileByID = (ProductData.ID, @escaping () -> Void) -> ProductProfileViewModel?
    
    @inlinable
    func isUserPersonal() -> Bool {
        
        !model.products.value.isEmpty && !model.onlyCorporateCards
    }
    
    @inlinable
    func getRootNavigation(
        c2gFlag: C2GFlag,
        orderCardFlag: OrderCardFlag,
        makeProductProfileByID: MakeProductProfileByID,
        select: RootViewSelect,
        notify: @escaping RootViewDomain.Notify,
        completion: @escaping (RootViewNavigation) -> Void
    ) {
        switch select {
        case let .orderCardResponse(orderCardResponse):
            completion(.orderCardResponse(orderCardResponse))
            
        case let .savingsAccount(orderAccountResponse):
            
            let detailsService = nanoServiceComposer.compose(
                createRequest: RequestFactory.createGetOperationDetailByPaymentIDRequest,
                mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
            )
            
            let details: OperationDetailSADomain.Model = {
                return makeDetailsButton { completion in
                    if let paymentOperationDetailId = orderAccountResponse.paymentOperationDetailId {
                        detailsService(.init(String(paymentOperationDetailId))) { response in
                            
                            switch response {
                                
                            case let .success(details):
                                completion(.success(.init(product: orderAccountResponse.product, details, { self.format(amount: $0, currencyCode: $1, style: .fraction)})))
                                
                            case let .failure(error):
                                completion(.failure(error))
                            }
                            _ = detailsService
                        }
                    }
                }
            }()
            
            if orderAccountResponse.paymentOperationDetailId != nil {
                details.event(.load)
            } else {
                details.event(.loaded(.success(.init(orderAccountResponse))))
            }
            
            let documentService = nanoServiceComposer.compose(
                createRequest: RequestFactory.createGetPrintFormForSavingsAccountRequest,
                mapResponse: RemoteServices.ResponseMapper.mapGetPrintFormForSavingsAccountResponse
            )
            
            let document = makeDocumentButton { completion in
                if let accountID = orderAccountResponse.accountId {
                    documentService((accountID, orderAccountResponse.paymentOperationDetailId)) { response in
                        
                        completion(response)
                        _ = documentService
                    }
                }
            }
            document.event(.load)
            
            completion(.savingsAccount(.init(
                context: .init(formattedAmount: format(amount: orderAccountResponse.amount, currency: "RUB"), status: orderAccountResponse.status.status),
                details: details,
                document: document
            ), { [weak model] in
                
                model?.handleProductsUpdateTotalAll()
            }))

        case let .openProduct(type):
            
            switch type {
            case let .card(kind):
                if orderCardFlag == .active {
                    
                    switch kind {
                    case .form:
                        break
                        
                    case .landing:
                        completion(.openProduct(openProduct(
                            type: type,
                            notify: notify
                        )))
                    }
                }
                
            case .creditCardMVP:
                completion(.openProduct(.creditCardMVP(
                    makeCreditCardMVP()
                )))
                
            case .savingsAccount:
                completion(.openProduct(openProduct(
                    type: type,
                    notify: notify
                )))
                
            default:
                break
            }
            
        case let .outside(outside):
            switch outside {
            case let .productProfile(id):
                if let profile = makeProductProfileByID(id, { notify(.dismiss) }) {
                    completion(.outside(.productProfile(profile)))
                } else {
                    completion(.failure(.makeProductProfileFailure(id)))
                }
                
            case let .tab(tab):
                completion(.outside(.tab(tab)))
            }
            
        case .scanQR:
            if isUserPersonal() {
                makeScanQR()
            } else {
                completion(.disabledForCorporate)
            }
            
        case .templates:
            if isUserPersonal() {
                makeTemplatesNode()
            } else {
                completion(.disabledForCorporate)
            }
            
        case let .standardPayment(type):
            initiateStandardPaymentFlow(type)
            
        case .searchByUIN:
            if isUserPersonal() {
                if c2gFlag.isActive {
                    completion(.searchByUIN(makeSearchByUIN()))
                } else {
                    completion(.updateForNewPaymentFlow)
                }
            } else {
                completion(.disabledForCorporate)
            }
            
        case .userAccount:
            makeUserAccount()
        }
        
        func makeScanQR() {
            
            let qrScanner = makeQRScannerBinder(c2gFlag: c2gFlag)
            let cancellables = bind(qrScanner)
            
            completion(.scanQR(.init(
                model: qrScanner,
                cancellables: cancellables
            )))
        }
        
        func bind(
            _ qrScanner: QRScannerDomain.Binder
        ) -> Set<AnyCancellable> {
            
            // PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer.swift:308
            let content = qrScanner.content.$state
                .compactMap { $0 }
                .delay(for: 0.1, scheduler: schedulers.main)
            // .debounce(for: 0.1, scheduler: scheduler)
                .sink {
                    
                    switch $0 {
                    case .cancelled:
                        notify(.dismiss)
                        
                    case .inflight:
                        // no need in inflight case - flow would flip it state isLoading to true on any select
                        break
                        
                    default:
                        break
                    }
                }
            
            let flow = qrScanner.flow.$state
                .compactMap(\.rootOutside)
                .sink { notify(.select(.outside($0))) }
            
            return [content, flow]
        }
        
        func makeTemplatesNode() {
            
            let templates = makeTemplates(.active) { notify(.dismiss) }
            let cancellables = bind(templates)
            
            completion(.templates(.init(
                model: templates,
                cancellables: cancellables
            )))
        }
        
        func bind(
            _ templates: RootViewModelFactory.Templates
        ) -> Set<AnyCancellable> {
            
            // handleTemplatesOutsideFlowState
            // MainViewModel.handleTemplatesFlowState(_:)
            
            // let share = ...
            // let isLoading = templates.$state.flip() // see extension
            
            let outside = templates.$state.sink {
                
                $0.notifyEvent.map(notify)
            }
            
            return [outside]
        }
        
        func makeUserAccount() {
            
            let userAccount = self.makeUserAccount { notify(.dismiss) }
            
            guard let userAccount
            else { return completion(.failure(.makeUserAccountFailure)) }
            
            completion(.userAccount(userAccount))
        }
        
        func initiateStandardPaymentFlow(
            _ type: ServiceCategory.CategoryType
        ) {
            self.initiateStandardPaymentFlow(ofType: type) {
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(.init(failure)))
                    
                case let .success(binder):
                    let node = binder.asNode(
                        transform: { $0.outcome },
                        notify: notify
                    )
                    completion(.standardPayment(node))
                }
            }
        }
    }
}

// MARK: - Adapters

private extension QRScannerDomain.FlowDomain.State {
    
    var rootOutside: RootViewSelect.RootViewOutside? {
        
        switch navigation {
        case let .outside(outside):
            switch outside {
            case .chat:
                return .tab(.chat)
            case .main:
                return .tab(.main)
            case .payments:
                return .tab(.payments)
            }
            
        default:
            return nil
        }
    }
}

private extension PaymentProviderPickerDomain.Navigation {
    
    var outcome: NavigationOutcome<RootViewSelect>? {
        
        switch self {
        case .alert, .destination: // keep explicit for exhaustivity
            return nil
            
        case let .outside(outside):
            switch outside {
            case .qr:       return .select(.scanQR)
            case .main:     return .select(.outside(.tab(.main)))
            case .back:     return .dismiss
            case .chat:     return .select(.outside(.tab(.chat)))
            case .payments: return .select(.outside(.tab(.payments)))
            }
        }
    }
}

private extension TemplatesListFlowState<TemplatesListViewModel, AnywayFlowModel> {
    
    var notifyEvent: RootViewDomain.FlowDomain.NotifyEvent? {
        
        switch outside {
        case .none:
            return nil
            
        case let .productID(productModel):
            return .select(.outside(.productProfile(productModel)))
            
        case let .tab(tab):
            switch tab {
            case .main:
                return .select(.outside(.tab(.main)))
                
            case .payments:
                return .select(.outside(.tab(.payments)))
            }
        }
    }
}

private extension RootViewNavigation.Failure {
    
    init(_ failure: RootViewModelFactory.StandardPaymentFailure) {
        
        switch failure {
        case let .makeStandardPaymentFailure(binder):
            self = .makeStandardPaymentFailure(binder)
            
        case let .missingCategoryOfType(categoryType):
            self = .missingCategoryOfType(categoryType)
        }
    }
}

// MARK: - Helpers

private extension RootViewNavigation {
    
    static let disabledForCorporate: Self = .failure(.featureFailure(.disabledForCorporate))
    
    static let updateForNewPaymentFlow: Self = .failure(.featureFailure(.updateForNewPaymentFlow))
}

private extension FeatureFailure {
    
    static let disabledForCorporate: Self = .init(title: "Информация", message: "Данный функционал не доступен\nдля корпоративных карт.\nОткройте продукт как физ. лицо,\nчтобы использовать все\nвозможности приложения.")
    
    static let updateForNewPaymentFlow: Self = .init(message: "Обновите приложение до последней версии, чтобы получить доступ к новому разделу.")
}

extension OrderAccountResponse.Status {
    
    var status: OpenSavingsAccountCompleteDomain.Complete.Context.Status {
        
        switch self {
        case .completed:
            return .completed
        case .inflight:
            return .inflight
        case .rejected:
            return .rejected
        case let .fraud(fraud):
            switch fraud {
            case .cancelled:
                return .fraud(.cancelled)
            case .expired:
                return .fraud(.expired)
            }
        case .suspend:
            return .suspend
        }
    }
}

private extension OpenSavingsAccountCompleteDomain.Details {
    init(
        product: ProductSelect.Product?,
        _ data: RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse,
        _ formattedAmount: @escaping (Decimal, String) -> String?
    ) {
        self.init(
            product: product,
            payeeAccountId: data.payeeAccountID,
            payeeAccountNumber: .dot + String(data.payeeAccountNumber?.suffix(4) ?? "") + .saRubWithDot,
            payerCardId: data.payerCardID,
            payerCardNumber: data.payerCardNumber,
            payerAccountId: data.payerAccountID,
            formattedAmount: formattedAmount(data.amount, data.payerCurrency),
            formattedFee: formattedAmount(data.payerFee, data.payerCurrency),
            dataForDetails: data.dateForDetail
        )
    }
}

private extension OpenSavingsAccountCompleteDomain.Details {
    init(
        _ data: OpenSavingsAccountDomain.OrderAccountResponse
    ) {
        self.init(
            product: nil,
            payeeAccountId: nil,
            payeeAccountNumber: .dot + String(data.accountNumber?.suffix(4) ?? "") + .saRubWithDot ,
            payerCardId: nil,
            payerCardNumber: nil,
            payerAccountId: nil,
            formattedAmount: nil,
            formattedFee: nil,
            dataForDetails: data.openData
        )
    }
}

private extension String {
    
    static let saRubWithDot: Self = "  ∙ Рублевый"
    static let dot: Self = "∙ "
}
