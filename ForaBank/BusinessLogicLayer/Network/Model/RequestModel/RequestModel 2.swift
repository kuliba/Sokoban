//
//  RequestModel.swift
//  Anna
//
//  Created by Igor on 07/02/2018.
//  Copyright © 2018 Anna Financial Service Ltd. All rights reserved.
//

import Foundation
import Alamofire

struct RequestModel: IRequestModel {
    var urlString: String
    var method: HTTPMethod
    var headers: [String: String]
    var parameters: [String: Any]?
    var showError = true

    struct Constant {
        static let appVersionKey = "app_version"
        static let osVersionKey = "os_version"
        static let osVersionValue = "ios"
    }

    init(urlString: String, method: HTTPMethod, headers: [String: String]) {
        self.urlString = urlString
        self.method = method
        self.headers = headers
        addAdditionalHeaders()
    }

    init(urlString: String, method: HTTPMethod, parameters: [String: Any]?, headers: [String: String]) {
        self.init(urlString: urlString, method: method, headers: headers)
        self.parameters = parameters
    }

    init(urlString: String, method: HTTPMethod, parameters: [String: Any]?, headers: [String: String], showError: Bool) {
        self.init(urlString: urlString, method: method, parameters: parameters, headers: headers)
        self.showError = showError
    }

    private mutating func addAdditionalHeaders() {
        let additionalHeaders = RequestModel.additionalHeaders()
        headers.merge(additionalHeaders) { (current, _) in current }
    }

    static func additionalHeaders() -> [String: String] {
        var headers = [String: String]()
        //headers[Constant.appVersionKey] = UIApplication.shortAppVersion()
//        headers[Constant.osVersionKey] = Constant.osVersionValue
        return headers
    }
}

extension RequestModel: CustomDebugStringConvertible {
    var debugDescription: String {
        let newLine = " \n"
        var result = method.rawValue + " " + urlString + newLine
        if let parameters = parameters, parameters.keys.count > 0 {
            result += "parameters: " + parameters.debugDescription + newLine
        }
        if headers.keys.count > 0 {
            result += "headers: " + headers.debugDescription + newLine
        }
        if showError {
            result += "showError: \(showError)"
        }
        return result
    }
}
