//
//  RootViewModelFactory+getRootNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine
import FlowCore

extension RootViewModelFactory {
    
    typealias MakeProductProfileByID = (ProductData.ID, @escaping () -> Void) -> ProductProfileViewModel?
    
    @inlinable
    func getRootNavigation(
        makeProductProfileByID: MakeProductProfileByID,
        select: RootViewSelect,
        notify: @escaping RootViewDomain.Notify,
        completion: @escaping (RootViewNavigation) -> Void
    ) {
        switch select {
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
            if model.onlyCorporateCards {
                completion(.outside(.tab(.main)))
            } else {
                makeScanQR()
            }
            
        case .templates:
            if model.onlyCorporateCards {
                completion(.outside(.tab(.main)))
            } else {
                makeTemplatesNode()
            }
            
        case .userAccount:
            makeUserAccount()
            
        case let .standardPayment(type):
            initiateStandardPaymentFlow(type)
        }
        
        func makeScanQR() {
            
            let qrScanner = makeQRScannerBinder()
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
