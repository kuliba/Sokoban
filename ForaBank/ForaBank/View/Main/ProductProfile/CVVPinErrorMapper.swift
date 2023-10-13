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
        _ data: CVVPinError.ChangePinError
    ) -> ErrorDomain  {
        
        if data.statusCode != 7051, data.retryAttempts == nil {
            return .errorScreen
        }

        let errorMessage: String = {
            if data.statusCode == 7051 { return String.simpleCode }
            if let retryAttempts = data.retryAttempts, retryAttempts > 0 {
                return String.incorrectСode
            }
            return data.errorMessage
        }()
        
        return .errorForAlert(.init(errorMessage))
    }
    
    static func map(
        _ data: CVVPinError.OtpError
    ) -> ErrorDomain  {
        
        let errorMessage: String = {
            return data.retryAttempts > 0 ? String.incorrectСode : String.technicalError
        }()
        
        return .errorForAlert(.init(errorMessage))
    }
}

extension String {
    static let technicalError: Self = "Возникла техническая ошибка"
    
    static let incorrectСode: Self = "Введен некорректный код.\nПопробуйте еще раз"
    
    static let simpleCode: Self = "Введенный PIN-код слишком простой.\nНеобходимо изменить его для\nповышения уровня безопасности"
}
