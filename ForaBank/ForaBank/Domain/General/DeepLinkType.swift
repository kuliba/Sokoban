//
//  DeepLinkType.swift
//  ForaBank
//
//  Created by Дмитрий on 27.07.2022.
//

import Foundation

enum DeepLinkType {
    
    case me2me(String)
    case c2b(URL)
    case c2bSubscribe(URL)
    case sbpPay(String)
    
    init?(url: URL) {
        
        switch url.absoluteString {
        case let c2bUrlString where c2bUrlString.contains("sbpay"):
            let tokenIntent = url.absoluteString.replacingOccurrences(of: "bank\(BankID.foraBankID.rawValue)://sbpay/tokenIntent/", with: "")
            self = .sbpPay(tokenIntent)
        
        case let c2bUrlString where c2bUrlString.contains("qr.nspk.ru"):
            self = .c2b(url)
            
        case let c2bSubscribeUrlString where c2bSubscribeUrlString.contains("sub.nspk.ru"):
            self = .c2bSubscribe(url)

        default:
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                  let queryItems = components.queryItems,
                  let parametr = queryItems.first?.value  else {
                return nil
            }
            
            let bankId = String(parametr.dropFirst(4))
            self = .me2me(bankId)
        }
    }
}
