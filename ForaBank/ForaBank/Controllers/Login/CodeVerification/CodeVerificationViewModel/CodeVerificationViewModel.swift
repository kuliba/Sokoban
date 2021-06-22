//
//  CodeVerificationViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 22.06.2021.
//

import Foundation

struct CodeVerificationViewModel {
    
    func getCode(completion: @escaping( _ error: String?) -> ()) {
        NetworkManager<GetCodeDecodebleModel>.addRequest(.getCode, [:], [:]) { model, error in
            if error != nil {
                guard let error = error else { return }
                completion(error)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    completion(nil)
                } else {
                    guard let error = model?.errorMessage else { return }
                    completion(error)
                }
            }
        }
    }
    
    
    
}
