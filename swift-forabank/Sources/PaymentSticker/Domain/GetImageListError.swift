//
//  GetImageListError.swift
//  
//
//  Created by Дмитрий Савушкин on 19.11.2023.
//

import Foundation

public enum GetImageListError: Error , Equatable {
    
    case error(
        statusCode: Int,
        errorMessage: String
    )
    case invalidData(statusCode: Int, data: Data)
}
