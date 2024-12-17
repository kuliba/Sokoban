//
//  IconDomain+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.05.2024.
//

import Combine

extension IconDomain {
    
    static var preview: MakeIconView {
        
        return { _ in
            
                return .init(
                    image: .cardPlaceholder,
                    publisher: Just(.cardPlaceholder).eraseToAnyPublisher()
                )
        }
    }
}
