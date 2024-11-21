//
//  RootViewModelFactory+makeQRScannerBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2024.
//

import Combine
import Foundation
import PayHubUI

extension RootViewModelFactory {
    
    func makeQRScannerBinder() -> QRScannerDomain.Binder {
        
        let qrScannerBinderComposer = QRScannerDomain.BinderComposer(
            delay: .milliseconds(100),
            getNavigation: getQRNavigation,
            makeContent: makeMakeQRScannerModel,
            schedulers: schedulers,
            witnesses: .default
        )
        
        return qrScannerBinderComposer.compose()
    }
}

private extension RootViewModelFactory {
    
    func getQRNavigation(
        select: QRScannerDomain.Select,
        notify: @escaping QRScannerDomain.Notify,
        completion: @escaping (QRScannerDomain.Navigation) -> Void
    ) {
        // TODO: - replace using QRBinderGetNavigationComposer
        
        switch select {
        case let .qrResult(qrResult):
            switch qrResult {
            case let .c2bSubscribeURL(url):
                let payments = ClosePaymentsViewModelWrapper(
                    model: model,
                    source: .c2bSubscribe(url),
                    scheduler: schedulers.main
                )
                
                completion(.payments(.init(
                    model: payments,
                    cancellable: bind(payments, with: notify)
                )))
                
            case let .c2bURL(url):
                let payments = ClosePaymentsViewModelWrapper(
                    model: model,
                    source: .c2b(url),
                    scheduler: schedulers.main
                )
                
                completion(.payments(.init(
                    model: payments,
                    cancellable: bind(payments, with: notify)
                )))
                
            default:
                break
            }
        }
    }
    
    // QRNavigationComposer.swift:201
    private func bind(
        _ wrapper: ClosePaymentsViewModelWrapper,
        with notify: @escaping QRScannerDomain.Notify
    ) -> AnyCancellable {
        
        wrapper.$isClosed.sink { _ in notify(.dismiss) }
    }
}

// MARK: - Adapters

private extension ContentWitnesses
where Content == QRScannerModel,
      Select == QRScannerDomain.Select {
    
    static var `default`: Self {
        
        return .init(
            emitting: { $0.selectPublisher },
            receiving: { content in { content.event(.reset) }}
        )
    }
}

private extension QRScannerModel {
    
    var selectPublisher: AnyPublisher<QRScannerDomain.Select, Never> {
        
        $state
            .compactMap(\.?.qrResult)
            .map(QRScannerDomain.Select.qrResult)
            .eraseToAnyPublisher()
    }
}

private extension QRModelWrapperState {
    
    var qrResult: QRResult? {
        
        guard case let .qrResult(qrResult) = self else { return nil }
        
        return qrResult
    }
}
