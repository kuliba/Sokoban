//
//  CategorySet.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import RemoteServices

typealias ServiceCategory = RemoteServices.ResponseMapper.GetServiceCategoryListResponse.Category

enum CategorySet {
    
    case all
    case list([ServiceCategory])
}
