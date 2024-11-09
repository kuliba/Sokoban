//
//  QRResult.swift
//
//
//  Created by Igor Malyarov on 09.11.2024.
//

import Foundation
import PayHub

enum QRResult<Operator, Provider, QRCode, QRMapping, Source> {
    
    case first(First<QRCode, Source>)
    case second(Second<Operator, Provider, QRCode, QRMapping>)
}

extension QRResult {
    
    init(_ qrModelResult: QRModelResult<Operator, Provider, QRCode, QRMapping, Source>) {
        
        switch qrModelResult {
        case let .c2bSubscribeURL(url):
            self = .first(.c2bSubscribe(url))
            
        case let .c2bURL(url):
            self = .first(.c2b(url))
            
        case let .failure(qrCode):
            self = .first(.failure(qrCode))
            
        case let .mapped(mapped):
            switch mapped {
            case let .missingINN(qrCode):
                self = .first(.missingINN(qrCode))
                
            case let .mixed(mixed):
                self = .second(.mixed(mixed))
                
            case let .multiple(multiple):
                self = .second(.multiple(multiple))
                
            case let .none(qrCode):
                self = .first(.none(qrCode))
                
            case let .provider(payload):
                self = .second(.provider(payload))
                
            case let .single(single):
                self = .second(.single(single))
                
            case let .source(source):
                self = .first(.source(source))
            }
            
        case let .sberQR(url):
            self = .second(.sberQR(url))
            
        case let .url(url):
            self = .first(.url(url))
            
        case .unknown:
            self = .first(.unknown)
        }
    }
    
    var qrModelResult: QRModelResult<Operator, Provider, QRCode, QRMapping, Source> {
        
        switch self {
        case let .first(a):
            switch a {
            case let .c2bSubscribe(url):
                return .c2bSubscribeURL(url)
                
            case let .c2b(url):
                return .c2bURL(url)
                
            case let .failure(qrCode):
                return .failure(qrCode)
                
            case let .missingINN(qrCode):
                return .mapped(.missingINN(qrCode))
                
            case let .none(qrCode):
                return .mapped(.none(qrCode))
                
            case let .source(source):
                return .mapped(.source(source))
                
            case let .url(url):
                return .url(url)
                
            case .unknown:
                return .unknown
            }
            
        case let .second(mapped):
            switch mapped {
            case let .mixed(mixed):
                return .mapped(.mixed(mixed))
                
            case let .multiple(multiple):
                return .mapped(.multiple(multiple))
                
                
            case let .provider(providerPayload):
                return .mapped(.provider(providerPayload))
                
            case let .sberQR(url):
                return .sberQR(url)
                
            case let .single(single):
                return .mapped(.single(single))
                
            }
        }
    }
}

enum First<QRCode, Source> {
    
    case c2bSubscribe(URL)
    case c2b(URL)
    case failure(QRCode)
    case missingINN(QRCode)
    case none(QRCode)
    case source(Source)
    case url(URL)
    case unknown
}

enum Second<Operator, Provider, QRCode, QRMapping> {
    
    case mixed(Mixed)
    case multiple(Multiple)
    case provider(ProviderPayload<Provider, QRCode, QRMapping>)
    case sberQR(URL)
    case single(Single)
    
    typealias Mixed = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias Multiple = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    typealias Single = SinglePayload<Operator, QRCode, QRMapping>
}
