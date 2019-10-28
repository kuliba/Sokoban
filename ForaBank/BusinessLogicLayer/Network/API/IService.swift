//
//  IService.swift
//  ForaBank
//
//  Created by Бойко Владимир on 24.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IProductService {
    func getProducts(completionHandler: @escaping (_ success: Bool, _ products: [Product]?) -> Void)
}
