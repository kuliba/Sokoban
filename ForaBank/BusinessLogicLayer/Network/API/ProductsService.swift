//
//  ProductsService.swift
//  ForaBank
//
//  Created by Бойко Владимир on 24.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import Alamofire

class ProductsService: IProductService {

    private let host: Host

    init(host: Host) {
        self.host = host
    }

    func getProducts(completionHandler: @escaping (Bool, [Product]?) -> Void) {
        var products = [Product]()
        let headers = NetworkManager.shared().headers
        let url = host.apiBaseURL + "rest/getProductList"

        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in

                if let json = response.result.value as? Dictionary<String, Any>,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, products)
                    return
                }

                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>, let data = json["data"] as? Array<Any> {
                        for productData in data {
                            guard let productData = productData as? Dictionary<String, Any>,
                                let product = Product.from(NSDictionary(dictionary: productData)) else { continue }
                     

                            products.append(product)
                        }
                        completionHandler(true, products)
                    } else {
                        print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, nil)
                    }

                case .failure(let error):
                    print("rest/getDepositList \(error) \(self)")
                    completionHandler(false, nil)
                }
        }
    }
}
