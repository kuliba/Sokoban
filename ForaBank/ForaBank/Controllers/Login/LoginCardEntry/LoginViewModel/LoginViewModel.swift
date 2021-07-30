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
        var cryptString = String()
        do {
            let aes = try AES(keyString: "\(KeyFromServer.secretKey)")

            let stringToEncrypt: String = "\(number)"
            
            print("String to encrypt:\t\t\t\(stringToEncrypt)")

            let encryptedData: Data = try aes.encrypt(stringToEncrypt)
            print("String encrypted (base64):\t\(encryptedData.base64EncodedString())")
            cryptString = encryptedData.base64EncodedString()
            let decryptedData: String = try aes.decrypt(encryptedData)
            print("String decrypted:\t\t\t\(decryptedData)")

        } catch {
            print("Something went wrong: \(error)")
        }
//        let pass = try? encription.encryptMessage(message: number, encryptionKey: KeyFromServer.secretKey? ?? "")
//        print(pass)
      
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


