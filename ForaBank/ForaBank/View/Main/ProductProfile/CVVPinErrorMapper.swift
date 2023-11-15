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
        
        if case let .server(statusCode, _) = error, statusCode != 7051 {
            return .errorScreen
        }
        
        let errorMessage: String = {
            
            switch error {
            case .activationFailure:
                return .technicalError
                
            case let .retry(_, _, retryAttempts):
                return retryAttempts > 0 ? .incorrectСode : .technicalError
                
            case let .server(_, message):
                return message

            case .serviceFailure:
                return .technicalError

            case .weakPIN:
                return .simpleCode
            }
        }()
        
        return .errorForAlert(.init(errorMessage))
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
