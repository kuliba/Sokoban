//
//  CallSpy.swift
//  
//
//  Created by Igor Malyarov on 07.12.2023.
//

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
