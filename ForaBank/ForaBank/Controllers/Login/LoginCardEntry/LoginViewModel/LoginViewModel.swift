//
//  LoginViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 21.06.2021.
//

import Foundation

class LoginViewModel {
   
    var encription = Encription()
    
    
    
    
    func checkCardNumber(with number: String, completion: @escaping(_ model: String?, _ error: String?) -> ()) {
        
        let body = [
            "cryptoversion": "2.0",
            "cardNumber": Encription().encryptAES(string: number)] as [String : AnyObject]
        
        NetworkManager<CheckClientDecodebleModel>.addRequest(.checkCkient, [:], body) { (model, error) in
            
            if error != nil {
                guard let error = error else { return }
                completion(nil, error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    guard let phone = model?.data?.phone else { return }
                    completion(phone,nil)
                } else {
                    guard let error = model?.errorMessage else { return }
                    completion(nil, error)
                }
            }
        }
    }
    
    
    
}

extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimalToString: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}


