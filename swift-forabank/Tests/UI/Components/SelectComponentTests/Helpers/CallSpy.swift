//
//  CallSpy.swift
//  
//
//  Created by Дмитрий Савушкин on 13.06.2024.
//

import Foundation

final class CallSpy<Payload> {
    
    private(set) var payloads = [Payload]()
    var callCount: Int { payloads.count }
    
    func call(payload: Payload) {
        
        payloads.append(payload)
    }
}

extension CallSpy where Payload == Void {
    
    func call() {
        
        self.call(payload: ())
    }
}
