//
//  RequestError.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.06.2021.
//

import Foundation

public enum RequestError : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
