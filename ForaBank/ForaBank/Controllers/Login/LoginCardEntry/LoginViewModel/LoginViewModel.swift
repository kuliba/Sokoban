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
            let aes = try AES(keyString: KeyFromServer.secretKey!)

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
//                    let decodedString = String(data: decodedData!, encoding: .utf8)!

//                    func testEnc() {
//
////                        let aesKey = password.padding(toLength: 32, withPad: "0", startingAt: 0)
//
//                        let aes = try? AES256(key: KeyFromServer.secretKey!, iv: AES256.randomIv())
//
//                        let decryptString = try? aes?.decrypt(data)
//                        print(decryptString)
//                    }
//                    testEnc()
//                    let str = model?.data?.phone?.data
                    var decryptPhone: String?
                    do {
                        let aes = try AES(keyString: KeyFromServer.secretKey!)
//                        let decryptedString = try AES256(key: KeyFromServer.secretKey!, iv: AES256.randomIv()).decrypt(data)
//                        print(decryptedString)
                        let decryptedData: String = try aes.decrypt(decodedData!)
                        print("String decrypted:\t\t\t\(decryptedData)")
                        decryptPhone = decryptedData
                    } catch {
                        print("Something went wrong: \(error)")
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


