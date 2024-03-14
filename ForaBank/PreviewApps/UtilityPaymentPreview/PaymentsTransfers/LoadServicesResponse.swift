//
//  LoadServicesResponse.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 10.03.2024.
//

enum LoadServicesResponse: Equatable {
    
    case failure
    case list([UtilityService]) // non-empty!
    case single(UtilityService)
}
