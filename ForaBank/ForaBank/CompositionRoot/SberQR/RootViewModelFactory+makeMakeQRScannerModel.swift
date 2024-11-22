//
//  RootViewModelFactory+makeQRScannerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Combine

extension RootViewModelFactory {
    
    func makeQRScannerModel() -> QRScannerModel {
        
        // TODO: make async and move all QR mapping from QRViewModel to special new QRResolver component
        
        let composer = QRScanResultMapperComposer(model: model)
        let mapper = composer.compose()
        
        return .init(
            mapScanResult: mapper.mapScanResult(_:_:),
            makeQRScanner: makeQRScanner,
            scheduler: schedulers.main
        )
    }
    
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
