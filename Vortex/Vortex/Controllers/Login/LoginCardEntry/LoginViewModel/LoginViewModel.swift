//
//  LoginViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 21.06.2021.
//

import Foundation

class LoginViewModel {
   
    var encription = Encription()

    func csrf(){
        /*
        AppDelegate.shared.getCSRF() { errorMessage in
        }
         */
    }
    
    func checkCardNumber(with number: String, completion: @escaping(_ model: String?, _ error: String?) -> ()) {
        var cryptString = String()

        do {
            guard let key = KeyFromServer.secretKey else {
                return
            }
            let aes = try AES(keyString: key)

            let stringToEncrypt: String = "\(number)"

            let encryptedData: Data = try aes.encrypt(stringToEncrypt)
            cryptString = encryptedData.base64EncodedString()
            let decryptedData: String = try aes.decrypt(encryptedData)

        } catch {
        }
        
        let body = [
            "cryptoVersion": "1.0",
            "cardNumber": cryptString] as [String : AnyObject]
        NetworkManager<CheckClientDecodebleModel>.addRequest(.checkCkient, [:], body) { (model, error) in
            
            if error != nil {
                guard let error = error else { return }
                completion(nil, error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    let data = model?.data?.phone?.data(using: .utf8)
                    var data1 = model?.data?.phone?.base64Decoded()
                    let decodedData = Data(base64Encoded: (model?.data?.phone)!)
                    var decryptPhone: String?
                    do {
                        guard let key = KeyFromServer.secretKey else {
                            return
                        }
                        let aes = try AES(keyString: key)
                        let decryptedData: String = try aes.decrypt(decodedData!)
                        decryptPhone = decryptedData
                    } catch {

                    }

                    let phone = decryptPhone
                    completion(phone,nil)
                } else {
                    guard let error = model?.errorMessage else { return }
                    completion(nil, error)
                }
            }
        }
    }
}


