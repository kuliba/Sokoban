//
//  TemplateEmitter.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.08.2024.
//

import Combine

protocol TemplateEmitter {
    
    var templatePublisher: AnyPublisher<PaymentTemplateData, Never> { get }
}
