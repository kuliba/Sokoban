//
//  CardDomain.swift
//  
//
//  Created by Andryusina Nataly on 12.10.2023.
//

import Tagged

/// A namespace.
public enum CardDomain {}

public extension CardDomain {
    
    typealias CardAction = (CardEvent) -> Void
    typealias CardId = Tagged<_CardId, Int>
    enum _CardId {}

    enum CardEvent {
        
        case copyCardNumber(String)
    }
}

/// A namespace.
public enum PinDomain {}

public extension PinDomain {
    
    typealias NewPin = Tagged<_NewPin, String>
    enum _NewPin {}
}

/// A namespace.
public enum OtpDomain {}

public extension OtpDomain {
    
    typealias Otp = Tagged<_Otp, String>
    enum _Otp {}
}

public enum ErrorDomain: Equatable {
    
    public typealias ErrorMessage = Tagged<_ErrorMessage, String>
    public enum _ErrorMessage {}

    case errorForAlert(ErrorMessage)
    case errorScreen
    
    public var message: ErrorMessage? {
        switch self {
            
        case let .errorForAlert(errorMessage):
            return errorMessage
        case .errorScreen:
            return nil
        }
    }
}

/// A namespace.
public enum PhoneDomain {}

public extension PhoneDomain {
    
    typealias Phone = Tagged<_Phone, String>
    enum _Phone {}
}
