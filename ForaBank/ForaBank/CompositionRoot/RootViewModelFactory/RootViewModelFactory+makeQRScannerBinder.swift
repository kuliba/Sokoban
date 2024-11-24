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
    
    @inlinable
    func makeQRScannerBinder() -> QRScannerDomain.Binder {
        
        return compose(getNavigation: getQRNavigation, makeContent: makeQRScannerModel, witnesses: .default)
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func getQRNavigation(
        select: QRScannerDomain.Select,
        notify: @escaping QRScannerDomain.Notify,
        completion: @escaping (QRScannerDomain.Navigation) -> Void
    ) {
        // TODO: - replace using QRBinderGetNavigationComposer
        
        switch select {
        case let .outside(outside):
            completion(.outside(outside))
            
        case let .qrResult(qrResult):
            switch qrResult {
            case let .c2bSubscribeURL(url):
                completion(.payments(makePaymentsNode(
                    payload: .source(.c2bSubscribe(url)),
                    notifyClose: { notify(.dismiss) }
                )))
                
            case let .c2bURL(url):
                completion(.payments(makePaymentsNode(
                    payload: .source(.c2b(url)),
                    notifyClose: { notify(.dismiss) }
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
