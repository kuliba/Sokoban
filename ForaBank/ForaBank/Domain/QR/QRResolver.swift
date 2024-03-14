//
//  QRResolver.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation
import SberQR

struct QRResolver {
    
    private let isSberQR: (URL) -> Bool
    
    init(isSberQR: @escaping (URL) -> Bool) {
        
        self.isSberQR = isSberQR
    }
}

extension QRResolver {
    
    func resolve(string: String) -> QRViewModel.ScanResult {
        
        if let url = URL(string: string) {
            
            if url.absoluteString.contains("qr.nspk.ru") {
                
                return .c2bURL(url)
                
            } else if url.absoluteString.contains("sub.nspk.ru") {
                
                return .c2bSubscribeURL(url)
                
            } else if isSberQR(url) {
                
                return .sberQR(url)
                
            } else if let qrCode = QRCode(string: string) {
                
                return .qrCode(qrCode)
                
            } else {
                
                return .url(url)
            }
            
        } else if let qrCode = QRCode(string: string) {
            
            return .qrCode(qrCode)
            
        } else {
            
            return .unknown
        }
    }
}
