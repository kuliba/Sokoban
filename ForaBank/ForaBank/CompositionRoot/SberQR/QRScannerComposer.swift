//
//  QRScannerComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class QRScannerComposer {
    
    let model: Model
    let utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.utilitiesPaymentsFlag = utilitiesPaymentsFlag
        self.scheduler = scheduler
    }
}

extension QRScannerComposer {
    
    func compose() -> QRScannerModel {
        
        // TODO: make async and move all QR mapping from QRViewModel to special new QRResolver component
        let qrResolve: QRViewModel.QRResolve = { [self] string in
            
            let resolver = QRResolver(isSberQR: self.model.isSberQR)
            
            return resolver.resolve(string: string)
        }
        
        let composer = QRScanResultMapperComposer(
            flag: utilitiesPaymentsFlag,
            model: model
        )
        let mapper = composer.compose()
        
        return .init(
            mapScanResult: mapper.mapScanResult(_:_:),
            makeQRScanner: { QRViewModel(closeAction: $0, qrResolve: qrResolve) },
            scheduler: scheduler
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
