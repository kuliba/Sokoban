//
//  MapService.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 05.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire
import RMMapper

class MapService: MapServiceProtocol {

//    private var isSigned: Bool = false
//    private var login: String? = nil
//    private var password: String? = nil
//    private var profile: Profile? = nil
//    private var myContext: Bool = false
    private let host: Host
//
    init(host: Host) {
        self.host = host
    }
    
    //MARK: Get Bank Branches
    ///для получания всех отображаемых на карте точек (JSON)
    func getBankBranches(headers: HTTPHeaders, completionHandler: @escaping (_ success: Bool, _ nsData: Data?, _ errorMessage: String?) -> Void){
        let url = "https://git.briginvest.ru/dbo/api/v2/smartfeed/bank_branches.json"
        Alamofire.request(url, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON {response in
                guard let dataBB = response.data else{
                    completionHandler(false, nil, "Что-то пошло не так")
                    return
                }
                completionHandler(true, dataBB, nil)
        }
    }
}
