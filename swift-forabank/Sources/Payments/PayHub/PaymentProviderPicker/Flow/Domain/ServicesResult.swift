//
//  ServicesResult.swift
//  
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public enum ServicesResult<Service, ServicesFailure> {
    
    case servicesFailure(ServicesFailure)
    case services(Services)
    
    public typealias Services = MultiElementArray<Service>
}

extension ServicesResult: Equatable where Service: Equatable, ServicesFailure: Equatable {}
