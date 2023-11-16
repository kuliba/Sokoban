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
            return .errorForAlert(.init(.technicalError))
            
        case let .retry(_, _, retryAttempts):
            return .errorForAlert(.init(retryAttempts > 0 ? .incorrectСode : .technicalError))
            
        case let .server(statusCode, _) where statusCode != 7051:
            return .errorScreen
            
        case let .server(_, message):
            return .errorForAlert(.init(message))
            
        case .serviceFailure:
            return .errorForAlert(.init(.technicalError))
            
        case .weakPIN:
            return .weakPinAlert( .init(String.simpleCode), .init("Изменить"))
        }
    }
    
    static func map(
        _ error: ConfirmationCodeError
    ) -> ErrorDomain  {
        
        let errorMessage: String = {
            
            switch error {
                
            case let .retry(_, _, retryAttempts):
                return retryAttempts > 0 ? String.incorrectСode : String.technicalError
            case .serviceFailure:
                return String.technicalError
            case let .server(_, message):
                return message
            }
        }()
        return .errorForAlert(.init(errorMessage))
    }
}

extension String {
    static let technicalError: Self = "Возникла техническая ошибка"
    
    static let incorrectСode: Self = "Введен некорректный код.\nПопробуйте еще раз"
    
    static let simpleCode: Self = "Введенный PIN-код слишком простой.\nНеобходимо изменить его для\nповышения уровня безопасности"
    
    static let cvvNotReceived: Self = "Не удалось получить CVV"

    static let tryLater: Self = "Попробуйте позже."
}
