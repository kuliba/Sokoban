//
//  Transformers+sberNumeric.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldModel

public extension Transformers {
    
    /// `SBER Providers`: `numeric` input should have period as decimal separator
    static let sberNumeric = Transform(build: {
        
        FilteringTransformer.numeric
        Transform { state in
            
            return .init(
                state.text.sberNumeric(),
                cursorPosition: state.cursorPosition
            )
        }
    })
}

private extension String {
    
    func sberNumeric() -> Self {
        
        var string = replacingOccurrences(of: ",", with: ".")
        
        // Ensure only one decimal point is allowed
        if string.components(separatedBy: ".").count > 2 {
            
            // If there are multiple periods, keep only the first one
            let firstPart = string.components(separatedBy: ".").first ?? ""
            let remainingParts = string.components(separatedBy: ".").dropFirst().joined()
            string = firstPart + "." + remainingParts.replacingOccurrences(of: ".", with: "")
        }
        
        return string
    }
}
