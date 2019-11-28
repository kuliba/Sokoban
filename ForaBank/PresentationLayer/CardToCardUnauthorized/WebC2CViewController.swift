//
//  WebC2CViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 22/11/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class WebC2CViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
      @IBOutlet weak var webC2C: WKWebView!
    var fee:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        func MD5(string: String) -> Data {
                let length = Int(CC_MD5_DIGEST_LENGTH)
                let messageData = string.data(using:.utf8)!
                var digestData = Data(count: length)

                _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
                    messageData.withUnsafeBytes { messageBytes -> UInt8 in
                        if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                            let messageLength = CC_LONG(messageData.count)
                            CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                        }
                        return 0
                    }
                }
                return digestData
            }

        
//        let sector =  "1009"
//        let amount = "1000"
//        let pan1 =  "4656260150230695"
//        let pan2 =  "4809388889655340"
//        let currency = "643"
//        let cvc =  "314"
//        let month =  "07"
//        let year =  "2024"
//        let fee =  "7000"
//        let signature =  String()
        
        
        let mdd5Plus = "1009" + "2200200111114591" + "05" + "2022" + "426" + "4809388889655340" + "1000" + "643"

        let mdd5Plus2 = "1009" + "1000" + "643" + "test"
        let MD5str = "1" + "100" + "643" + "test"
        
        
        

        //Test:
        let md5Data = MD5(string: mdd5Plus2)

        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        print(md5Hex)
        
        let  md5Base64 = md5Data.base64EncodedString()
        print("md5Base64: \(md5Base64)")
        let normHex = md5Hex.base64Encoded()
        print(normHex)
        let purchase = "1009"+"565668"+"test"
        let purchaseMD5 = MD5(string: purchase)
       let md5Purchase =  purchaseMD5.map { String(format: "%02hhx", $0) }.joined()
     let purchaseBase64 =  md5Purchase.base64Encoded()
        print("PURCHASE \(purchaseBase64)")
        let headers = [
                          "Content-Type": "application/x-www-form-urlencoded"
                      ]
                      let parameters = [
                          "sector": 1009,
                          "amount": 1000,
                          "pan1": "4656260150230695",
                          "pan2": "4809388889655340",
                          "currency": 643,
                          "cvc": "314",
                          "month": "07",
                          "year": "2024",
                          "fee": 7000,
                          "signature": String()
                      ] as [String : Any]
                  
                      Alamofire.request("https://test.best2pay.net/webapi/P2PTransfer", method: .post, parameters: parameters, encoding:  URLEncoding.httpBody, headers: headers).responseJSON { (response:DataResponse<Any>) in

                          switch(response.result) {
                          case.success(let data):
                              let intData:Int = data as! Int
                              print("success \((intData)/100)")
                              self.fee = (intData)/100
                          case.failure(let error):
                              print("Not Success",error)
                          }
                          let data = response.request
                      }
        
        let urlP2P = URL(string: "https://test.best2pay.net/webapi/P2PTransfer?sector=1009&signature=90d058fe1259aecf1f564c9d3a6a25c1&action=pay")
         let requestP2P = URLRequest(url: urlP2P!)
            
            
        webC2C.load(requestP2P)
        
       
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
