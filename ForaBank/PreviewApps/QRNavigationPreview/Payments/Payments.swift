//
//  Payments.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import Foundation

final class Payments {
    
    private let isClosedSubject = CurrentValueSubject<Bool, Never>(false)
    
    let url: URL
    
    init(url: URL) {
        
        self.url = url
    }
    
    var isClosedPublisher: AnyPublisher<Bool, Never> {
        
        isClosedSubject.eraseToAnyPublisher()
    }
    
    func close() {
        
        isClosedSubject.send(true)
    }
}
