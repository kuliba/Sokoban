//
//  IRequestModel.swift
//  Anna
//
//  Created by Igor on 07/02/2018.
//  Copyright © 2018 Anna Financial Service Ltd. All rights reserved.
//

import Foundation
import Alamofire

protocol IRequestModel: CustomDebugStringConvertible {
    var urlString: String {get}
    var method: HTTPMethod {get}
    var parameters: [String: Any]? {get}
    var headers: [String: String] {get}
    var showError: Bool {get}
}
