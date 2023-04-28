//
//  AnyTransformer+Ext.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

public extension AnyTransformer {
    
    init(limit: Int? = nil, regex: String? = nil) {
        
        self.init {
            
            var string = $0
            
            if let limit = limit {
                
                string = String(string.prefix(limit))
            }
            
            if let regex = regex {
                
                string = RegexTransformer(regexPattern: regex).transform(string)
            }
            
            return string
        }
    }
}
