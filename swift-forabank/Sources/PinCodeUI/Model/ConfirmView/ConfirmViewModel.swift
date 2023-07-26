//
//  ConfirmViewModel.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import Foundation

public class ConfirmViewModel: ObservableObject {
   
    let maxDigits: Int
    
    @Published var pin: String
    @Published var isDisabled: Bool

    var handler: (String, @escaping (Bool) -> Void) -> Void
    
    public init(
        maxDigits: Int = 6,
        pin: String = "",
        isDisable: Bool = false,
        handler: @escaping (String, @escaping (Bool) -> Void) -> Void
    ) {
        
        self.maxDigits = maxDigits
        self.pin = pin
        self.isDisabled = isDisable
        self.handler = handler
    }

    func submitPin() {
        
        guard !pin.isEmpty else { return }
        
        if pin.count == maxDigits {
            
            isDisabled = true
            handler(pin) { isSuccess in
                
                if isSuccess {
                    
                    // код корректный, перейти на след экран
                    
                } else {
                    // код некорректный, сброс теущего
                    
                    self.pin = ""
                    self.isDisabled = false
                }
            }
        }
        
        if pin.count > maxDigits {
            
            pin = String(pin.prefix(maxDigits))
            submitPin()
        }
    }
    
    func getDigit(at index: Int) -> String? {
        
        if index >= self.pin.count { return nil }
        
        return self.pin.digits[index].numberString
    }
}

private extension String {
    
    var digits: [Int] {
        
        return self.compactMap{ Int(String($0)) }
    }
}

private extension Int {
    
    var numberString: String {
        
        guard self < 10 else { return "0" }
        
        return String(self)
    }
}
