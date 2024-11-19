//
//  RootViewModelFactory+makeGetRootNavigation.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.11.2024.
//

import Combine

extension RootViewModelFactory {
    
    func makeGetRootNavigation(
        makeQRScanner: @escaping () -> QRScannerModel
    ) -> RootViewDomain.GetNavigation {
        
        return { [bind] select, notify, completion in
            
            switch select {
            case .scanQR:
                let qrScanner = makeQRScanner()
                let cancellable = bind(qrScanner, notify)
                completion(.scanQR(.init(
                    model: qrScanner,
                    cancellable: cancellable
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
            // .debounce(for: 0.1, scheduler: scheduler)
            .sink {
                
                switch $0 {
                case .cancelled:
                    notify(.dismiss)
                    
                case .inflight:
                    // no need in inflight case - flow would flip it state isLoading to true on any select
                    break
                    
                case let .qrResult(qrResult):
                   // notify(.select(.qr(.result(qrResult))))
                    break
                }
            }
    }
}
