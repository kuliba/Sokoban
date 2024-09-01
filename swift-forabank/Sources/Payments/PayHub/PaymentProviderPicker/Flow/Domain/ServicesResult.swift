//
//  ServicesResult.swift
//  
//
//  Created by Igor Malyarov on 01.09.2024.
//

public enum ServicesResult<ServicePicker, ServicesFailure> {
    
    case servicePicker(ServicePicker)
    case servicesFailure(ServicesFailure)
}

extension ServicesResult: Equatable where ServicePicker: Equatable, ServicesFailure: Equatable {}
