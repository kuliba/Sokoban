//
//  String+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 07.12.2021.
//

import Foundation

extension String {
    
    func contained(in list: [String]) -> Bool {
        
        for item in list {
            
            if self.contains(item) {
                
                return true
            }
        }
        
        return false
    }
}
