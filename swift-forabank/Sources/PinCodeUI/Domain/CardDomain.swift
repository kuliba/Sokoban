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
    
    public typealias ButtonTitle = Tagged<_ButtonTitle, String>
    public enum _ButtonTitle {}
    
    case pinError(PinError)
    case cvvError(CvvError)
    
    public var message: ErrorMessage? {
        
        switch self {
        case let .cvvError(error):
            switch error {
            case let .errorForAlert(errorMessage):
                return errorMessage
                
            case let .noRetry(errorMessage, _):
                return errorMessage
            }
            
        case let .pinError(error):
            switch error {
            case let .errorForAlert(errorMessage):
                return errorMessage
                
            case .errorScreen:
                return nil
                
            case let .weakPinAlert(errorMessage, _):
                return errorMessage
            }
        }
    }
    
    public var buttonTitle: ButtonTitle? {
        switch self {
        case let .cvvError(error):
            switch error {
            case let .noRetry(_, buttonTitle):
                return buttonTitle
                
            default:
                return nil
            }
            
        case let .pinError(error):
            switch error {
            case let .weakPinAlert(_, buttonTitle):
                return buttonTitle
                
            default:
                return nil
            }
        }
    }
    
    public enum PinError: Equatable {
        case errorForAlert(ErrorMessage)
        case errorScreen
        case weakPinAlert(ErrorMessage, ButtonTitle)
    }
    
    public enum CvvError: Equatable {
        case errorForAlert(ErrorMessage)
        case noRetry(ErrorMessage, ButtonTitle)
    }
}

/// A namespace.
public enum PhoneDomain {}

public extension PhoneDomain {
    
    typealias Phone = Tagged<_Phone, String>
    enum _Phone {}
}
