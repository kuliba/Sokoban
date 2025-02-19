//
//  RootViewModelFactory+makeQRScannerModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Combine

extension RootViewModelFactory {
    
    @inlinable
    func makeQRScannerModel(
        c2gFlag: C2GFlag
    ) -> QRScannerModel {
        
        return .init(
            mapScanResult: mapScanResult(result:completion:),
            makeQRScanner: { [makeQRScanner] in makeQRScanner(c2gFlag, $0) },
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
        c2gFlag: C2GFlag,
        closeAction: @escaping () -> Void
    ) -> QRScanner {
        
        let getUIN: QRResolverDependencies.GetUIN = { qrCode in
            
            if c2gFlag.isActive {
                return qrCode.uin ?? qrCode.docIdx
            } else {
                return nil
            }
        }
        
        let qrResolve = makeQRResolve(.init(
            getUIN: getUIN,
            isSberQR: model.isSberQR(_:)
        ))
        
        return QRViewModel(
            closeAction: closeAction,
            qrResolve: qrResolve,
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

private extension QRCode {
    
    var uin: String? {
        
        guard let uin = rawData["uin"],
              !uin.isEmpty // no extra validation
        else { return nil }
        
        return uin
    }
    
    var docIdx: String? {
        
        guard let docIdx = rawData["DocIdx".lowercased()],
              !docIdx.isEmpty // no extra validation
        else { return nil }
        
        return docIdx
    }
}
