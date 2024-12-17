//
//  ForaApplication.swift
//  ForaBank
//
//  Created by Max Gribov on 22.04.2022.
//

import UIKit

class ForaApplication: UIApplication {
    
    var didTouchEvent: (() -> Void)?
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        guard let didTouchEvent = didTouchEvent else {
            return
        }
        
        switch event.type {
        case .touches:
            didTouchEvent()
            
        default:
            break
        }
    }
}
