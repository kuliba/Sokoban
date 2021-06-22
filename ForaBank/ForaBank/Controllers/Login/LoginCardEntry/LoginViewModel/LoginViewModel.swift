//
//  LoginViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 21.06.2021.
//

import Foundation

struct LoginViewModel {
   
    
    func checkCardNumber(with number: String, completion: @escaping(_ model: String?, _ error: String?) -> ()) {
        
        let body = ["cardNumber": "\(number)"] as [String : AnyObject]
        
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

