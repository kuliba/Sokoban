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
            let qrScanner = makeQRScannerBinder()
            let cancellable = bind(qrScanner.content, using: notify)
            
            completion(.scanQR(.init(
                model: qrScanner,
                cancellable: cancellable
            )))
            
        case .templates:
            let templates = makeMakeTemplates(
                closeAction: { notify(.dismiss) }
            )
            let cancellables = bind(templates, with: notify)
            
            completion(.templates(.init(
                model: templates,
                cancellables: cancellables
            )))
        }
    }
    
    private func bind(
        _ scanQR: QRScannerModel,
        using notify: @escaping RootViewDomain.Notify
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
    
    private func bind(
        _ templates: RootViewModelFactory.Templates,
        with notify: @escaping RootViewDomain.Notify
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
}

// MARK: - Adapters

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
