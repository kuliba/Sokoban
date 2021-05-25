//
//  OperationsListService.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

//var OperationsList = [OperationsList]
class OperationListService: OperationProtocolService{

    private let host: Host

    init(host: Host) {
        self.host = host
    }
    
    
    let urlString =  Host.shared.apiBaseURL + "rest/getOperatorsList"
    var operationArray = OperationsList()
    var listService = OperationsList()
    func getOperations(headers: HTTPHeaders, completionHandler: @escaping (Bool, OperationsList?, String?) -> Void) {
        guard let url = Foundation.URL(string: urlString) else { return }
        let _ = URLRequest(url: url)
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: MultiRange(200..<300, 401..<406))
            .responseJSON { response in
                let json = response.data
                let _ = response.result
            do{
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(OperationsList.self, from: json!)
                self.listService = jsonData
                completionHandler(true, self.listService, "\(self.listService.errorMessage ?? "nil")")
            } catch {
                print(error)
                completionHandler(false, self.listService, "\(self.listService.errorMessage ?? "nil")")

            }
        }
    }

}
