//
//  RootViewModelFactory+getRootNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine

extension RootViewModelFactory {
    
    @inlinable
    func getRootNavigation(
        select: RootViewSelect,
        notify: @escaping RootViewDomain.Notify,
        completion: @escaping (RootViewNavigation) -> Void
    ) {
        switch select {
        case let .outside(outside):
            completion(.outside(outside))
            
        case .scanQR:
            makeScanQR()
            
        case .templates:
            makeTemplatesNode()
            
        case .userAccount:
            makeUserAccount()
            
        case let .standardPayment(type):
            initiateStandardPaymentFlow(type)
        }
        
        func makeScanQR() {
            
            let qrScanner = makeQRScannerBinder()
            let cancellable = bind(qrScanner.content)
            
            completion(.scanQR(.init(
                model: qrScanner,
                cancellable: cancellable
            )))
        }
        
        func bind(
            _ scanQR: QRScannerModel
        ) -> AnyCancellable {
            
            // PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer.swift:308
            return scanQR.$state
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
        }
        
        func makeTemplatesNode() {
            
            let templates = makeTemplates { notify(.dismiss) }
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
                    completion(.standardPayment(.init(
                        model: binder,
                        cancellable: bind(binder)
                    )))
                }
            }
        }
        
        func bind(
            _ binder: PaymentProviderPickerDomain.Binder
        ) -> AnyCancellable {
            
            return binder.flow.$state
                .compactMap(\.rootEvent)
                .sink { notify(.select($0)) }
        }
    }
}

// MARK: - Adapters

private extension PaymentProviderPickerDomain.FlowDomain.State {
    
    var rootEvent: RootEvent? {
        
        switch navigation {
        case .outside(.qr):   return .scanQR
        case .outside(.main): return .outside(.tab(.main))
        default:               return nil
        }
    }
}

private extension TemplatesListFlowState<TemplatesListViewModel, AnywayFlowModel> {
    
    var notifyEvent: RootViewDomain.FlowDomain.NotifyEvent? {
        
        switch outside {
        case .none:
            return nil
            
        case let .productID(productID):
            return .select(.outside(.productProfile(productID)))
            
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
