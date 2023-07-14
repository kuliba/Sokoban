//
//  Task+megaYield.swift
//  
//
//  Created by Igor Malyarov on 29.06.2023.
//

extension Task where Success == Never, Failure == Never {
    
    static func megaYield(count: UInt = 40) async {
        
        for _ in 1...count {
            
            await Task<Void, Never>.detached (priority: .background) {
                
                await Task<Never, Never>.yield()
                
            }.value
        }
    }
}
