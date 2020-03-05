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
    func getBankBranches(headers: HTTPHeaders, completionHandler: @escaping (_ success: Bool, NSDataAsset?, _ errorMessage: String?) -> Void){
        //https://git.briginvest.ru/dbo/api/v2/smartfeed/bank_branches.json
        let url = "https://git.briginvest.ru/dbo/api/v2/smartfeed/bank_branches.json"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { [unowned self] response in
                print(response.result)
        }
    }
}
