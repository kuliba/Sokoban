/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation
import Alamofire

class TestRegService: RegServiceProtocol {
    
    func checkClient(headers: HTTPHeaders,
                     cardNumber: String,
                     login: String,
                     password: String,
                     phone: String,
                     verificationCode: Int,
                     completionHandler: @escaping (_ success:Bool,_ errorMessage: String?) -> Void) {
        completionHandler(true, nil)
    }
    
    func doRegistration(headers: HTTPHeaders, completionHandler: @escaping (Bool, String?, String?, String?) -> Void) {
        completionHandler(true, nil, nil, nil)
    }
    
    func verifyCode(headers: HTTPHeaders, verificationCode: Int, completionHandler: @escaping (Bool, String?) -> Void) {
        completionHandler(true, nil)
    }
}
