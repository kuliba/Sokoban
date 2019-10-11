//
//  INetworkTransport.swift
//  Anna
//
//  Created by Igor on 06/02/2018.
//  Copyright © 2018 Anna Financial Service Ltd. All rights reserved.
//

import Foundation
import Alamofire

protocol INetworkTransport {
    func send(requestModel: IRequestModel, completion: @escaping NetworkTransportCompletion)
}
