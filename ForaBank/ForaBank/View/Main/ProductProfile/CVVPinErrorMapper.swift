//
//  CVVPinErrorMapper.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 13.10.2023.
//

import Foundation
import PinCodeUI

struct CVVPinErrorMapper {
    
    static func map(
        _ error: ChangePINError
    ) -> ErrorDomain  {
        
        switch error {
            
        case .activationFailure:
            return .pinError(.errorForAlert(.init(.technicalError)))
            
        case let .retry(_, _, retryAttempts):
            return .pinError(.errorForAlert(.init(retryAttempts > 0 ? .incorrectСode : .technicalError)))
            
        case let .server(statusCode, _) where statusCode != 7051:
            return .pinError(.errorScreen)
            
        case let .server(_, message):
            return .pinError(.errorForAlert(.init(message)))
            
        case .serviceFailure:
            return .pinError(.errorForAlert(.init(.technicalError)))
            
        case .weakPIN:
            return .pinError(.weakPinAlert( .init(String.simpleCode), .init("Изменить")))
        }
    }
    
    static func map(
        _ error: ConfirmationCodeError
    ) -> ErrorDomain  {
        
        switch error {
            
        case let .retry(_, _, retryAttempts):
            return retryAttempts > 0 ? .cvvError(.errorForAlert(.init(String.incorrectСode))) : .cvvError(.noRetry(.init(String.technicalError), .init("Ок")))
            
        case .serviceFailure, .server:
            return .cvvError(.noRetry(.init(String.technicalError), .init("Ок")))
        }
    }
}

extension String {
    static let technicalError: Self = "Возникла техническая ошибка"
    
    static let incorrectСode: Self = "Введен некорректный код.\nПопробуйте еще раз"
    
    static let simpleCode: Self = "Введенный PIN-код слишком простой.\nНеобходимо изменить его для\nповышения уровня безопасности"
    
    static let cvvNotReceived: Self = "Не удалось получить CVV"

    static let tryLater: Self = "Попробуйте позже"
}
