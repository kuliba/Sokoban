//
//  RootViewModelFactory+makeGetRootNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine

extension RootViewModelFactory {
    
    @inlinable
    func makeGetRootNavigation() -> RootViewDomain.GetNavigation {
        
        return { [weak self] select, notify, completion in
            
            guard let self else { return }
            
            switch select {
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
        []
    }
}
