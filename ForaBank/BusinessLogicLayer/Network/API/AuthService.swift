/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire
import RMMapper
import SwiftyRSA
import CryptoSwift


class AuthService: AuthServiceProtocol {

    private var isSigned: Bool = false
    private var login: String? = nil
    private var password: String? = nil
    private var profile: Profile? = nil
    private var myContext: Bool = false
    private let host: Host
    private var activeCsrf: Bool = false
//    var delegate2 = RSAUtils?/
    weak var delegate: KeyPairGeneration?
    
    var error: Unmanaged<CFError>?
    var ownPrivKey: SecKey?
    var publicSecKeyRSA: SecKey?
    var publicKeyBytes: Data?

    var bytes: Data?
    var dataEncrypted:Data?
    var pubFromCert: SecKey?
    var pubFromServ: SecKey?
    var sendBase64ToServ: String?
    var tokenFromServ: String?
    var secretKey: Data?
    
func otherPublicSecKey(data: Data?) -> SecKey? {
       var error: Unmanaged<CFError>? = nil
//    let privData1 = Data(base64Encoded: data!)

       var publicKeyFormatting: SecKey?
       let privRaw2 = data?.advanced(by: 23)

       return privRaw2?.withUnsafeBytes { (unsafeBytes) -> SecKey? in
          let bytes2 =  unsafeBytes.baseAddress?.advanced(by: 0).bindMemory(to: UInt8.self, capacity: 0)
           let CFPrivData1 = CFDataCreate(nil, bytes2, unsafeBytes.count - 0)
           print(unsafeBytes.count)
           let attributes =  [
               kSecAttrKeySizeInBits: 384,
                  kSecAttrKeyType: kSecAttrKeyTypeEC,
                   SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32,
                  kSecAttrKeyClass: kSecAttrKeyClassPublic,
              ] as CFDictionary

           let pubKey = SecKeyCreateWithData(CFPrivData1!, attributes as CFDictionary, &error)
           pubFromServ = pubKey!
        
            bytes = SecKeyCopyExternalRepresentation(pubKey!, &error) as Data?
           if let publicKey = SecKeyCreateWithData(CFPrivData1!, attributes, &error) {
               return publicKey
           } else {
               print("other EC public: (String(describing: error))")
               return nil
           }
       }
   }
   func encryptWithRSAKey(_ data: Data, rsaKeyRef: SecKey, padding: SecPadding) -> Data? {
        let blockSize = SecKeyGetBlockSize(rsaKeyRef)
        let maxChunkSize = blockSize - 11

        var decryptedDataAsArray = [UInt8](repeating: 0, count: data.count / MemoryLayout<UInt8>.size)
        (data as NSData).getBytes(&decryptedDataAsArray, length: data.count)

        var encryptedData = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while (idx < decryptedDataAsArray.count ) {
            var idxEnd = idx + maxChunkSize
            if ( idxEnd > decryptedDataAsArray.count ) {
                idxEnd = decryptedDataAsArray.count
            }
            var chunkData = [UInt8](repeating: 0, count: maxChunkSize)
            for i in idx..<idxEnd {
                chunkData[i-idx] = decryptedDataAsArray[i]
            }

            var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var encryptedDataLength = blockSize

            let status = SecKeyEncrypt(rsaKeyRef, padding, chunkData, idxEnd-idx, &encryptedDataBuffer, &encryptedDataLength)
            if ( status != noErr ) {
                NSLog("Error while ecrypting: %i", status)
                return nil
            }
            //let finalData = removePadding(encryptedDataBuffer)
            encryptedData += encryptedDataBuffer


            idx += maxChunkSize
        }

        return Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedData.count)
    }

    func encryptAES(string: String) -> String?{
        
        do {
            
            let digest = string.data(using: .utf8)!
            let salt = AES256.randomSalt()
            
            let iv = AES256.randomIv()
            print("Randomize\(iv)")
            
            guard let key = secretKey else {
                return nil
            }
            print(key)
            
            var aes = try AES256(key: key, iv: iv)
            
            let encrypted = try aes.encrypt(digest)
            let decrypted = try aes.decrypt(encrypted)
            
            print("Encrypted: \(encrypted.hexadecimal)")
            print("Decrypted: \(decrypted)")
            
            let string1 = encrypted.base64EncodedData()
            print(string1)
            
            let data: Data = decrypted
            if let string = String(data: string1, encoding: .utf8) {
                print(string)
            } else {
                print("not a valid UTF-8 sequence")
            }
//            print("Password: \(password)")
//            print("Key: \(key.hexString)")
//            print("IV: \(iv.hexString)")
            print("Salt: \(salt.hexadecimal)")
            print(" ")
            
            print("#! /bin/sh")
            print("echo \(digest.hexadecimal) | xxd -r -p > digest.txt")
            print("echo \(encrypted.hexadecimal) | xxd -r -p > encrypted.txt")
//            print("openssl aes-256-cbc -K \(key.hexString) -iv \(iv.hexString) -e -in digest.txt -out encrypted-openssl.txt")
//            print("openssl aes-256-cbc -K \(key.hexString) -iv \(iv.hexString) -d -in encrypted.txt -out decrypted-openssl.txt")
            return encrypted.base64EncodedString()
        } catch {
            print("Failed")
            print(error)
            }
        return nil
    }

func removePadding(_ data: [UInt8]) -> [UInt8] {
       var idxFirstZero = -1
       var idxNextZero = data.count
       for i in 0..<data.count {
           if ( data[i] == 0 ) {
               if ( idxFirstZero < 0 ) {
                   idxFirstZero = i
               } else {
                   idxNextZero = i
                   break
               }
           }
       }
       var newData = [UInt8](repeating: 0, count: idxNextZero-idxFirstZero-1)
       for i in idxFirstZero+1..<idxNextZero {
           newData[i-idxFirstZero-1] = data[i]
       }
       return newData
   }

    func addPemToKey(publicKeySec: SecKey) -> Data{
            
            let fullKeyData = CFDataCreateMutable(kCFAllocatorDefault, CFIndex(0))
            if fullKeyData != nil {
                //Fixed schema header per key size in bits
//                var headerBytes256r1: [UInt8] = [0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00] //uncomment if you use 256 bit EC keys
                var header384r1: [UInt8] = [0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00] //384 bit EC keys
                //var header521r1: [UInt8] = [0x30, 0x81, 0x9B, 0x30, 0x10, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x23, 0x03, 0x81, 0x86, 0x00] // For 521 bit EC keys
                let headerSize = CFIndex(header384r1.count)
                let cfdata = SecKeyCopyExternalRepresentation(publicKeySec, &error)

                CFDataAppendBytes(fullKeyData, &header384r1, headerSize)
                CFDataAppendBytes(fullKeyData, CFDataGetBytePtr(cfdata), CFDataGetLength(cfdata)) //pub = data you got from SecKeyCopyExternalRepresentation

                var pem = ""
                //pem.append("-----BEGIN PUBLIC KEY-----\n") //uncomment if needed
                pem.append((fullKeyData as Data?)?.base64EncodedString() ?? "")
                print((fullKeyData as Data?)?.base64EncodedString() ?? "")
                
                //pem.append("\n-----END PUBLIC KEY-----\n") //uncomment if needed

                //do something with pem
                return fullKeyData! as Data
            }
        return fullKeyData! as Data
        }
    
    func encodingSecKey(data : SecKey){
        if let cfdata = SecKeyCopyExternalRepresentation(data, &error){
           let data:Data = cfdata as Data
           let b64Key = data.base64EncodedString()
            print(b64Key)
        }
    }
    
func publicKey(for certificate: SecCertificate) -> SecKey? {
//                let otherPublicKey = otherPublicSecKey(data:  Data(base64Encoded: otherKey)!)!
        if #available(iOS 12.0, *) {
            
            pubFromCert = SecCertificateCopyKey(certificate)
            let str = KeyFromServer.publicKey!
            let lastKey: CFData?
            let keyWithPem = addPemToKey(publicKeySec: KeyPair.publicKey!)

            lastKey = SecKeyCreateDecryptedData(pubFromCert!, .rsaEncryptionRaw,  Data(base64Encoded: str)! as CFData, &error)
            let newData = SecKeyCreateEncryptedData(pubFromCert!, .rsaEncryptionPKCS1, keyWithPem as! CFData, &error)
            let b64Data = (newData as? Data)?.base64EncodedString()
            sendBase64ToServ = (newData as? Data)?.base64EncodedString()
            let data = (lastKey as? Data)?.advanced(by: 136)
         
            otherPublicSecKey(data: data)
//            decryptWithRSAKey(Data(base64Encoded: str)!, rsaKeyRef: pubFromCert!, padding: .PKCS1)
     
//            let clear = try? encrypted?.decrypted(with: pubFromCert!, padding: .PKCS1)
            return SecCertificateCopyKey(certificate)
        } else if #available(iOS 10.3, *) {
            
            pubFromCert = SecCertificateCopyPublicKey(certificate)
            return SecCertificateCopyPublicKey(certificate)
        } else {
            var possibleTrust: SecTrust?
            SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
            guard let trust = possibleTrust else { return nil }
            var result: SecTrustResultType = .unspecified
            SecTrustEvaluate(trust, &result)
            pubFromCert = SecTrustCopyPublicKey(trust)

            return SecTrustCopyPublicKey(trust)
        }
    }

func encryptedPublicKey() -> SecKey? {
    
    let pubicKeyPem = KeyFromServer.publicKeyCert

    let certInDer = Data(base64Encoded: pubicKeyPem!, options: .ignoreUnknownCharacters)
    let secCert = SecCertificateCreateWithData(nil, certInDer! as CFData) // certInDer is Certificate(.der) data
               var keychainQueryDictionary = [String : Any]()
            var serialNumber: Int?
               if let tempSecCert = secCert {
                keychainQueryDictionary = [kSecClass as String : kSecClassCertificate, kSecValueRef as String : tempSecCert, kSecAttrLabel as String: "My Certificate", kSecAttrSerialNumber as String: serialNumber ?? 0]
               }

        return  publicKey(for: secCert!)
   }
    
    func computeSharedSecret(ownPrivateKey: SecKey, otherPublicKey: SecKey) -> Data? {
       let algorithm:SecKeyAlgorithm = SecKeyAlgorithm.ecdhKeyExchangeStandard
       let params = [SecKeyKeyExchangeParameter.requestedSize.rawValue: 32, SecKeyKeyExchangeParameter.sharedInfo.rawValue: Data()] as [String: Any]
       
       var error: Unmanaged<CFError>? = nil
       print(otherPublicKey)
        if let sharedSecret: Data = SecKeyCopyKeyExchangeResult(ownPrivateKey, algorithm, otherPublicKey, params as CFDictionary, &error) as Data? {
            
    
            secretKey = Data(base64Encoded: sharedSecret.base64EncodedString())?.dropLast(16)
//            secretKey = secretKey?.base64EncodedString().data(using: .utf8)?.dropLast(16)
           SecKeyCopyExternalRepresentation(ownPrivateKey, &error)
            
           return sharedSecret
       } else {
           print("key exchange: (String(describing: error))")
       }
       return nil
    }
    
    init(host: Host) {
        self.host = host
    }

    func isSignedIn(completionHandler: @escaping (_ success: Bool) -> Void) {
        completionHandler(isSigned)
    }
    func activeCsrf(completionHandler: @escaping (_ success: Bool) -> Void) {
        completionHandler(activeCsrf)
    }
    

    func csrf(headers: HTTPHeaders, completionHandler: @escaping (_ success: Bool, _ headers: HTTPHeaders?) -> Void) {
        let url = Host.shared.apiBaseURL + "csrf"
        Alamofire.request(url, headers: headers)
            .responseJSON { [unowned self] response in
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil)
                    return
                }

                switch response.result {
                case .success:
                    var newHeaders: [String: String] = [:]
                    for c in Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.cookies ?? [] {
                        if c.name == "JSESSIONID" {
                            newHeaders[c.name] = c.value
                        }
                    }
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Dictionary<String, Any>,
                        let headerName = data["headerName"] as? String,
                        let cert = data["cert"] as? String,
                        let pk = data["pk"] as? String,
                        let token = data["token"] as? String {
                        tokenFromServ = token
                        let certSeparator = cert.replace(string: "\r", replacement: "").replace(string: "\n", replacement: "")
                            .components(separatedBy: "-----END CERTIFICATE----------BEGIN CERTIFICATE-----")
                        KeyFromServer.publicKeyCert = certSeparator[0].replace(string: "-----BEGIN CERTIFICATE-----", replacement: "")
                        KeyFromServer.privateKeyCert = certSeparator[1].replace(string: "-----END CERTIFICATE-----", replacement: "")
                        KeyFromServer.publicKey = pk
                                               
                       let pubkeyFromCert = encryptedPublicKey()
                        
                        let shared = computeSharedSecret(ownPrivateKey: KeyPair.privateKey!, otherPublicKey: pubFromServ!)
                        
                    
                        let ectoRsa = SecKeyCreateEncryptedData(KeyPair.publicKey!, .rsaEncryptionRaw, Data(base64Encoded: pk) as! CFData, &error)

                        
                       let newData = encryptWithRSAKey(Data(base64Encoded: pk)!, rsaKeyRef: KeyPair.privateKey!, padding: .PKCS1)
                        newHeaders[headerName] = token
                        print("csrf newHeaders \(newHeaders)")
                        activeCsrf = true
                        keyExchange(headers: newHeaders, key: "123", completionHandler: completionHandler)
                        completionHandler(true, newHeaders)
                    } else {
                        print("csrf cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil)
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }

        }
    }
    
    func keyExchange(headers: HTTPHeaders, key: String,completionHandler: @escaping (_ success: Bool, _ headers: HTTPHeaders?) -> Void) {
        let url = Host.shared.apiBaseURL + "keyExchange"
        let parameters: [String: AnyObject] = [
            "data": (sendBase64ToServ ?? "") as AnyObject,
            "token" : tokenFromServ as AnyObject
        ]
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil)
                    return
                }

                switch response.result {
                case .success:
//                    var newHeaders: [String: String] = [:]
//                    for c in Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.cookies ?? [] {
//                        if c.name == "JSESSIONID" {
//                            newHeaders[c.name] = c.value
//                        }
//                    }
                    if let json = response.result.value as? Dictionary<String, Any>,
                       let data = json["data"] as? Dictionary<String, Any>{
                        completionHandler(true, headers)
                    } else {
                        print("csrf cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil)
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil)
                }

        }
    }
    

    func loginDo(headers: HTTPHeaders, login: String, password: String, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        let url = Host.shared.apiBaseURL + "login.do"
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "login": encryptAES(string: login) as AnyObject,
            "password": encryptAES(string: password) as AnyObject,
            "token": FCMToken.fcmToken as AnyObject,
//            "pushDeviceId" : UIDevice.current.identifierForVendor?.uuidString as AnyObject,
            "version": "1.0" as AnyObject,
            "verificationCode": 0 as AnyObject
        ]
        if parameters["version"] as! String == "1.0"{
            UserSettingsStorage.auth = true
        }

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                print("login.do result: \(response.result)") // response serialization result
//                print("JSON: \(String(describing: response.value))") // serialized json response
//                print("JSON: \(String(describing: response.request?.httpBody))") // serialized json response
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage)
                    return
                }
                switch response.result {
                case .success:
                    print("login.do result: \(String(describing: response.result.value))")
                    self.login = login
                    self.password = password
                    UserDefaults.standard.set(headers["X-XSRF-TOKEN"], forKey: "TokenAccess")
                    let tokenAccess = UserDefaults.standard.object(forKey: "TokenAccess")
                   print(tokenAccess ?? "")                    //let dataCode = response.result.value as? Dictionary<String, Any>
                    //let json = dataCode!["data"] as? String
                    completionHandler(true, nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, "login result validation failure")
                }
        }
    }
    func prepareResetPassword(headers: HTTPHeaders, login: String, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        let url = Host.shared.apiBaseURL + "prepareResetPassword"
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "login": cleanNumber(number: login) as AnyObject,
            "password": "Srting" as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                print("login.do result: \(response.result)") // response serialization result
                //                print("JSON: \(String(describing: response.value))") // serialized json response
                //                print("JSON: \(String(describing: response.request?.httpBody))") // serialized json response
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage)
                    return
                }
                switch response.result {
                case .success:
                    print("prepareResetPassword result: \(String(describing: response.result.value))")
                    self.login = login
                    completionHandler(true, nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, "prepareResetPassword result validation failure")
                }
        }
    }

    func newPasswordReset(headers: HTTPHeaders, password: String, completionHandler: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        let url = Host.shared.apiBaseURL + "resetPassword"
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "login": "String" as AnyObject,
            "password": password as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": 0 as AnyObject
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                print("login.do result: \(response.result)") // response serialization result
                //                print("JSON: \(String(describing: response.value))") // serialized json response
                //                print("JSON: \(String(describing: response.request?.httpBody))") // serialized json response
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, errorMessage)
                    return
                }
                switch response.result {
                case .success:
                    print("prepareResetPassword result: \(String(describing: response.result.value))")
                    self.password = password
                    completionHandler(true, nil)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, "prepareResetPassword result validation failure")
                }
        }
    }

    func changePassword(headers: HTTPHeaders, oldPassword: String, newPassword: String, completionHandler: @escaping (Bool, String?) -> Void) {
        let url = Host.shared.apiBaseURL + "rest/changePassword"
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "newPassword": newPassword as AnyObject,
            "oldPassword": oldPassword as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
        ]

        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in

                print("changePassword result: \(response.result)") // response serialization result
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(String(describing: self))")
                    completionHandler(false, errorMessage)
                    return
                }
                switch response.result {
                case .success:
                    print("prepareResetPassword result: \(String(describing: response.result.value))")
                    completionHandler(true, nil)
                case .failure(let error):
                    print("\(error) \(String(describing: self))")
                    completionHandler(false, "prepareResetPassword result validation failure")
                }
        }
    }

    func checkVerificationCode(headers: HTTPHeaders, code: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        let url = Host.shared.apiBaseURL + "verify/checkVerificationCode"
        let parametersForUserNotification = [
        "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString,
        "pushFCMtoken": FCMToken.fcmToken as AnyObject,
        "model": UIDevice().model,
         "operationSystem": "IOS"
        ] as [String : Any]
        
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "pushFCMtoken": FCMToken.fcmToken as AnyObject,
            "pushDeviceId": UIDevice.current.identifierForVendor!.uuidString as AnyObject,
            "verificationCode": Int(code) as AnyObject
        ]
        print("verify/checkVerificationCode parameters \(parameters))")
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

//                print("verify/checkVerificationCode result: \(response.result)") // response serialization result
//                print("JSON: \(String(describing: response.result.value))") // serialized json response
                guard let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String, result == "OK" else {
                        print("\(String(describing: response.result.value as? Dictionary<String, Any>)) \(self)")
                        completionHandler(false)
                        return
                }

                switch response.result {
                case .success:
                    print("verify/checkVerificationCode result: \(String(describing: response.result.value))")
                    self.isSigned = true
                    self.login = nil
                    self.password = nil
                    NetworkManager.shared().isSignedIn { (isSignIn) in
                            NetworkManager.shared().installPushDevice(parameters: parametersForUserNotification, auth: true) { (success, errorMessage) in
                                if success{
                                    print("Это пуши \(success)")
                                } else {
                                    print(errorMessage)
                                }
                        }
                    }
                    completionHandler(true)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false)
                }
        }
    }
    func checkCodeResetPassword(headers: HTTPHeaders, code: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        let url = Host.shared.apiBaseURL + "resetPasswordCheckCode"
        let parameters: [String: AnyObject] = [
            "appId": "AND" as AnyObject,
            "fingerprint": false as AnyObject,
            "login": login as AnyObject,
            "password": password as AnyObject,
            "token": headers["X-XSRF-TOKEN"] as AnyObject,
            "verificationCode": Int(code) as AnyObject
        ]
        print("verify/checkVerificationCode parameters \(parameters))")
        Alamofire.request(url, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                //                print("verify/checkVerificationCode result: \(response.result)") // response serialization result
                //                print("JSON: \(String(describing: response.result.value))") // serialized json response
                guard let json = response.result.value as? Dictionary<String, Any>,
                    let result = json["result"] as? String, result == "OK" else {
                        print("\(String(describing: response.result.value as? Dictionary<String, Any>)) \(self)")
                        completionHandler(false)
                        return
                }

                switch response.result {
                case .success:
                    print("verify/checkVerificationCode result: \(String(describing: response.result.value))")
                    self.isSigned = true
                    self.login = nil
                    self.password = nil
                    completionHandler(true)
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false)
                }
        }
    }

    func logOut(completionHandler: @escaping (_ success: Bool) -> Void) {
        isSigned = false
        profile = nil
        completionHandler(true)
    }

    func getProfile(headers: HTTPHeaders, completionHandler: @escaping (_ success: Bool, Profile?, _ errorMessage: String?) -> Void) {
        if profile != nil {
            completionHandler(true, profile, nil)
            return
        }

        let url = Host.shared.apiBaseURL + "rest/getPerson"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { [unowned self] response in

                //                print("csrf result: \(response.result)")  // response serialization result
                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, nil, errorMessage)
                    return
                }

                switch response.result {
                case .success:
                    //                    print("JSON: \(json)") // serialized json response
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Dictionary<String, Any>,
                        let firstName = data["firstname"] as? String,
                        let lastName = data["lastname"] as? String,
                        let patronymic = data["patronymic"] as? String {
                        var imageURL: String? = nil
                        if let users = data["users"] as? Array<Dictionary<String, Any>>,
                            let imageUrl = users[0]["userPic"] as? String {
                            imageURL = imageUrl
                        }
                        self.profile = Profile.init(firstName: firstName,
                                                    lastName: lastName,
                                                    patronymic: patronymic,
                                                    imageURL: imageURL)
//                        print("rest/getPerson result: \(String(describing: response.result.value))")
                        print("rest/getPerson result: \(firstName), \(lastName), \(imageURL ?? "nil")")
                        completionHandler(true, self.profile, nil)
                    } else {
                        print("rest/getPerson cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil, "")
                    }
                case .failure(let error):
                    print("\(error) \(self)")
                    completionHandler(false, nil, "get profile result validation failure")
                }
        }
    }
    static func encrypt(string: String, publicKey: String?) -> SecKey? {
            guard let publicKey = publicKey else { return nil }

            let keyString = publicKey.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----\n", with: "").replacingOccurrences(of: "\n-----END PUBLIC KEY-----", with: "")
            guard let data = Data(base64Encoded: keyString) else { return nil }

            var attributes: CFDictionary {
                return [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                        kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                        kSecAttrKeySizeInBits   : 2048,
                        kSecReturnPersistentRef : kCFBooleanTrue] as CFDictionary
            }

            var error: Unmanaged<CFError>? = nil
            guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
                print(error.debugDescription)
                return nil
            }
        return secKey
        }
    func base64PaddingWithEqual(encoded64: String) -> String {
      let remainder = encoded64.count % 4
      if remainder == 0 {
        return encoded64
      } else {
        // padding with equal
        let newLength = encoded64.count + (4 - remainder)
        return encoded64.padding(toLength: newLength, withPad: "=", startingAt: 0)
      }
    }
    
    
}

extension String
{
    func fromBase64() -> String
    {
        let data = NSData.init(base64Encoded: self, options: []) ?? NSData()
        return String(data: data as Data, encoding: String.Encoding.utf8) ?? ""
    }
}



extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        print(data.base64EncodedString())
        return data
    }
    
}


extension Data {
    func copyBytes<T>(as _: T.Type) -> [T] {
        return withUnsafeBytes { (bytes: UnsafePointer<T>) in
            Array(UnsafeBufferPointer(start: bytes, count: count / MemoryLayout<T>.stride))
        }
    }
}
extension Data {
    
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
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

extension String {
    /// Expanded encoding
    ///
    /// - bytesHexLiteral: Hex string of bytes
    /// - base64: Base64 string
    enum ExpandedEncoding {
        /// Hex string of bytes
        case bytesHexLiteral
        /// Base64 string
        case base64
    }

    /// Convert to `Data` with expanded encoding
    ///
    /// - Parameter encoding: Expanded encoding
    /// - Returns: data
    func data(using encoding: ExpandedEncoding) -> Data? {
        switch encoding {
        case .bytesHexLiteral:
            guard self.count % 2 == 0 else { return nil }
            var data = Data()
            var byteLiteral = ""
            for (index, character) in self.enumerated() {
                if index % 2 == 0 {
                    byteLiteral = String(character)
                } else {
                    byteLiteral.append(character)
                    guard let byte = UInt8(byteLiteral, radix: 16) else { return nil }
                    data.append(byte)
                }
            }
            return data
        case .base64:
            return Data(base64Encoded: self)
        }
    }
}

