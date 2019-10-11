//
//  NetworkTransport.swift
//  Anna
//
//  Created by Igor on 06/02/2018.
//  Copyright © 2018 Anna Financial Service Ltd. All rights reserved.
//

import UIKit
import Alamofire

typealias NetworkTransportCompletion = (_ response: DataResponse<Any>) -> Void

class RequestDescription {
    let requestModel: IRequestModel
    let completion: NetworkTransportCompletion

    init(requestModel: IRequestModel, completion: @escaping NetworkTransportCompletion) {
        self.requestModel = requestModel
        self.completion = completion
    }
}

class NetworkTransport: INetworkTransport {
    struct Constant {
        static let timeoutInterval: TimeInterval = 15
        static let timeoutErrorCode: Int = -1001
    }

    static let defaultInstance = NetworkTransport()
    private var logger = Logger()
    var queue: [RequestDescription] = []
    var suspend = false

    var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constant.timeoutInterval
        configuration.timeoutIntervalForResource = Constant.timeoutInterval
        return SessionManager(configuration: configuration)
    }()

    func send(requestModel: IRequestModel, completion: @escaping NetworkTransportCompletion) {
        let lockQueue = DispatchQueue.init(label: "com.anna.ios.LockQueue")
        lockQueue.sync() {
            logger.write(string: requestModel.debugDescription)
            if requestModel.urlString.contains("refresh") {
                startRefrshRequest(requestModel: requestModel, completion: completion)
                return
            }
            let description = RequestDescription(requestModel: requestModel, completion: completion)
            queue.append(description)

            if suspend || queue.count != 1 {
                return
            }

            startRequest(with: description)
        }

    }

    func startRefrshRequest(requestModel: IRequestModel, completion: @escaping NetworkTransportCompletion) {
        self.suspend = true
        sessionManager.request(requestModel.urlString, method: requestModel.method, parameters: requestModel.parameters, encoding: JSONEncoding.default, headers: requestModel.headers).validate().responseJSON {[weak self] response in
            guard let `self` = self else { return }
            self.logger.write(string: response.debugDescription)
            completion(response)
        }
    }

    func startRequest(with requestDescription: RequestDescription) {
        let requestModel = requestDescription.requestModel
        let completion = requestDescription.completion

        sessionManager.request(requestModel.urlString, method: requestModel.method, parameters: requestModel.parameters, encoding: JSONEncoding.default, headers: requestModel.headers).validate().responseJSON {[weak self] response in
            guard let `self` = self else { return }
            self.logger.write(string: response.debugDescription)
            switch response.result {
            case .failure(let error):
//                if self.proccess(error: error, response: response) {
//                    self.suspend = true
//                    return
//                }
                break
            default: break
            }
            completion(response)
            self.didFinishRequest(requestDescription)
        }
    }

    func didFinishRequest(_ request: RequestDescription) {
        self.queue = Array(self.queue.dropFirst())
        guard let first = queue.first else {
            return
        }

        startRequest(with: first)
    }

//    private func proccess(error: Error, response: DataResponse<Any>) -> Bool {
//        let nsError = error as NSError
//        if nsError.code == NetworkError.ConnectionErrorReason.timedOut.rawValue {
//            let alertService = ApplicationAssembly.shared.container.resolve(IAlertService.self)
//            alertService?.show(title: nil, message: NSLocalizedString("Universal alert message", comment: ""), cancelButtonTitle: nil, okButtonTitle: NSLocalizedString("Ok", comment: ""), cancelCompletion: nil, okCompletion: nil)
//            return false
//        }
//
//        if let request = response.request, let url = request.url, url.absoluteString.contains("/sign") {
//            return false
//        }
//
//        if let afError = error as? AFError, let code = afError.responseCode, code == 401 {
//
//            let service = RefreshService.shared
//            self.logger?.write(string: "Ask to refresh: \(response.debugDescription)")
//            service.refreshToken(with: false) { token in
//                if let token = token {
//                    var newQueue = [RequestDescription]()
//                    for requst in self.queue {
//                        let headers = BaseRequest().headers(withToken: token)
//                        let requestModel = requst.requestModel
//                        let model = RequestModel(urlString: requestModel.urlString, method: requestModel.method, parameters: requestModel.parameters, headers: headers, showError: requestModel.showError)
//                        let newDescription = RequestDescription(requestModel: model, completion: requst.completion)
//                        newQueue.append(newDescription)
//                    }
//                    self.queue = newQueue
//                } else {
//                    self.queue.removeAll()
//                }
//                self.suspend = false
//                guard let first = self.queue.first else {
//                    return
//                }
//                self.startRequest(with: first)
//            }
//            return true
//        }
//
//        return false
//
//    }
}
