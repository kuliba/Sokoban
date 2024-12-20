//
//  RootViewModelFactory+makeQRScannerModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Combine

extension RootViewModelFactory {
    
    @inlinable
    func makeQRScannerModel() -> QRScannerModel {
        
        // TODO: make async and move all QR mapping from QRViewModel to special new QRResolver component
        
        let composer = QRScanResultMapperComposer(model: model)
        let mapper = composer.compose()
        
        return .init(
            mapScanResult: mapScanResult(result:completion:),
            makeQRScanner: makeQRScanner,
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func mapScanResult(
        result: QRViewModel.ScanResult,
        completion: @escaping (QRModelResult) -> Void
    ) {
        schedulers.interactive.schedule { [weak self] in
            
            self?.mapScanResult(result, completion)
        }
    }
    
    @inlinable
    func makeQRScanner(
        closeAction: @escaping () -> Void
    ) -> QRScanner {
        
        QRViewModel(
            closeAction: closeAction, 
            qrResolve: resolveQR,
            scanner: scanner
        )
    }
}

extension QRViewModel: QRScanner {
    
    var scanResultPublisher: AnyPublisher<QRViewModel.ScanResult, Never> {
        
        action
            .compactMap { $0 as? QRViewModelAction.Result }
            .map(\.result)
            .eraseToAnyPublisher()
    }
}
