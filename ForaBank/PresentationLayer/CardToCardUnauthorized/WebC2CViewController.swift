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

class WebC2CViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
      @IBOutlet weak var webC2C: WKWebView!
    var fee:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        let headers = [
                          "Content-Type": "application/x-www-form-urlencoded"
                      ]
                      let parameters = [
                          "sector": 881,
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
                          //let data = response.request
                      }
        
        //let url = URL(string: "https://www.google.com")
        //let request = URLRequest(url: url!)
        let urlP2P = URL(string: "https://pay.best2pay.net/webapi/P2PTransfer?sector=4324&code=643")
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
