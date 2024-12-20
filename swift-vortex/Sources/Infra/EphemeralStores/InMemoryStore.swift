//
//  InMemoryStore.swift
//
//
//  Created by Igor Malyarov on 12.10.2024.
//

public actor InMemoryStore<Value> {
    
    private var value: Value?
    
    public init(value: Value? = nil) {
     
        self.value = value
    }
    
    public func insert(_ value: Value) {
        
        self.value = value
    }
    
    public func retrieve() -> Value? {
        
        value
    }
    
    public func delete() {
        
        self.value = nil
    }
}
