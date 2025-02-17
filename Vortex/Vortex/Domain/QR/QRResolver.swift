//
//  QRResolver.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation
import SberQR

struct QRResolverDependencies {
    
    let getUIN: GetUIN
    let isSberQR: IsSberQR
    
    typealias GetUIN = (QRCode) -> String?
    typealias IsSberQR = (URL) -> Bool
}

struct QRResolver {
    
    private let dependencies: QRResolverDependencies
    
    init(
        dependencies: QRResolverDependencies
    ) {
        self.dependencies = dependencies
    }
}

extension QRResolver {
    
    func resolve(string: String) -> QRViewModel.ScanResult {
        
        let qrCode = QRCode(string: string)
        
        if let url = URL(string: string) {
            
            if let c2 = url.c2 {
                return c2
            }
            
            if dependencies.isSberQR(url) {
                return .sberQR(url)
            }
            
            if qrCode == nil {
                return .url(url)
            }
        }
        
        if let qrCode {
            return dependencies.getUIN(qrCode).map { .uin($0) } ?? .qrCode(qrCode)
        }
        
        return .unknown
    }
}

private extension URL {
    
    var c2: QRViewModel.ScanResult? { c2bURL ?? c2bSubscribeURL }
    
    private var c2bURL: QRViewModel.ScanResult? {
        
        guard absoluteString.contains("qr.nspk.ru") else { return nil }
        
        return .c2bURL(self)
    }
    
    private var c2bSubscribeURL: QRViewModel.ScanResult? {
        
        guard absoluteString.contains("sub.nspk.ru") else { return nil }
        
        return .c2bSubscribeURL(self)
    }
}
