//
//  CallSpy.swift
//
//
//  Created by Igor Malyarov on 31.03.2024.
//

final class CallSpy<Payload, Response> {
    
    private(set) var payloads = [Payload]()
    private let response: Response
    
    init(response: Response) {
        
        self.response = response
    }
}

extension CallSpy {
    
    var callCount: Int { payloads.count }
    
    func call(payload: Payload) -> Response {
        
        payloads.append(payload)
        return response
    }
}

extension CallSpy where Payload == Void {
    
    func call() -> Response {
        
        self.call(payload: ())
    }
}

extension CallSpy where Response == Void {
    
    convenience init() {
        
        self.init(response: ())
    }
}

extension CallSpy {
    
    func call<A, B>(_ a: A, _ b: B) -> Response
    where Payload == (A, B) {
        
        self.call(payload: (a, b))
    }
}
