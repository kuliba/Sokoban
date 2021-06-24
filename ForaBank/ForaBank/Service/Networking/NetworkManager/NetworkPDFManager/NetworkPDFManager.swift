//
//  NetworkPDFManager.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.06.2021.
//

import Foundation

final class NetworkPDFManager {
    
    static func addRequest( //_ requestType: RouterManager,
                           _ urlParametrs: [String: String],
                            _ requestBody: [String: AnyObject] ) {
        
        let r = RouterManager.getPrintForm
        
        guard var request = r.request() else { return }
        
        let s = RouterSassionConfiguration()
        let session = s.returnSession()
        
        if let token = CSRFToken.token {
            request.allHTTPHeaderFields = ["X-XSRF-TOKEN": token]
        }
        //   request.allHTTPHeaderFields = addHeader    +++++++++Singlton
        
        if request.httpMethod != "GET" {
        
        /// URL Parameters
        if var urlComponents = URLComponents(url: request.url!,
                                             resolvingAgainstBaseURL: false), !urlParametrs.isEmpty {

            urlComponents.queryItems = [URLQueryItem]()

            urlParametrs.forEach({ (key, value) in
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            })

            request.url = urlComponents.url
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }

        /// Request Body
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonAsData
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            debugPrint(NetworkError.encodingFailed)
        }
        
        }
        
        let task = session.downloadTask(with: request) { data, response, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = handleNetworkResponse(response)
                switch result {
                case .success:
                    guard data != nil else {
                        print("PDF : \(NetworkResponse.noData.rawValue)")
                        return
                    }
                case .failure(let networkFailureError):
                    print("PDF : \(networkFailureError)")
                }
            }
        }
        task.resume()
        
        func handleNetworkResponse(_ response: HTTPURLResponse) -> SessionResult<String>{
           switch response.statusCode {
           case 200...299: return .success
           case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
           case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
           case 600: return .failure(NetworkResponse.outdated.rawValue)
           default: return .failure(NetworkResponse.failed.rawValue)
           }
       }
    }
    
}
