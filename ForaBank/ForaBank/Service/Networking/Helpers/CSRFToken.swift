//
//  CSRFToken.swift
//  ForaBank
//
//  Created by Mikhail on 19.06.2021.
//

import Foundation
import Combine

struct CSRFToken {
    static var token: String? {
        didSet {
            print("DEBUG: CSRFToken установлен")
            tokenPublisher.send(token)
        }
    }
    
    //FIXME: temp hack to receave token updates in model.
    //It will be removed (and CSRFToken also) in the refactoring process
    static var tokenPublisher: CurrentValueSubject<String?, Never> = .init(nil)
}
