//
//  ServerAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation
import Combine

public final class ServerAgent: NSObject {
    
    private lazy var session: URLSession = {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    private lazy var sessionCached: URLSession = {
        
        let configuration = URLSessionConfiguration.default
        
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.urlCache = URLCache.downloadCache
        
        return URLSession(configuration: configuration)
    }()
    
    private let baseURL: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let logError: (String) -> Void
    private let logMessage: (String) -> Void
    private let sendAction: (ServerAgentAction) -> Void
    
    public var cookies: [HTTPCookie]?
    
    public init(
        baseURL: String,
        encoder: JSONEncoder,
        decoder: JSONDecoder,
        logError: @escaping (String) -> Void,
        logMessage: @escaping (String) -> Void,
        sendAction: @escaping (ServerAgentAction) -> Void
    ) {
        self.baseURL = baseURL
        self.encoder = encoder
        self.decoder = decoder
        self.logError = logError
        self.logMessage = logMessage
        self.sendAction = sendAction
    }
}

// MARK: - Execute Command

extension ServerAgent {
    
    public func executeCommand<Command>(
        command: Command,
        completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void
    ) where Command : ServerCommand {
        
        do {
            
            let request = try request(with: command)
            logMessage("data request: \(request)")
            session.dataTask(with: request) {[unowned self] data, response, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    
                    completion(.failure(.emptyResponse))
                    return
                }
                
                if response.statusCode == 200 {
                    
                    self.sendAction(.networkActivityEvent)
                    
                } else {
                    
                    if response.statusCode == 401 {
                        
                        self.sendAction(.notAuthorized)
                    }
                    
                    completion(.failure(.unexpectedResponseStatus(response.statusCode)))
                    return
                }
                
                if command.cookiesProvider == true,
                   let headers = response.allHeaderFields as? [String: String],
                   let url = request.url {
                    
                    let responseCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                    if responseCookies.count > 0 {
                        
                        self.cookies = responseCookies
                    }
                }
                
                guard let data = data else {
                    completion(.failure(.emptyResponseData))
                    return
                }
                
                do {
                    
                    let response = try decoder.decode(Command.Response.self, from: data)
                    if response.statusCode == .userNotAuthorized {
                        
                        self.sendAction(.notAuthorized)
                    }
                    completion(.success(response))
                    
                } catch {
                    
                    completion(.failure(.corruptedData(error)))
                }
                
            }.resume()
            
        } catch {
            
            completion(.failure(ServerAgentError.requestCreationError(error)))
        }
    }
}

// MARK: - Execute Download Command

extension ServerAgent {
    
    public func executeDownloadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerDownloadCommand {
        
        do {
            
            let request = try downloadRequest(with: command)
            logMessage("download request: \(request)")
            sessionCached.downloadTask(with: request) { localFileURL, response, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    
                    completion(.failure(.emptyResponse))
                    return
                }
                
                if response.statusCode == 200 {
                    
                    self.sendAction(.networkActivityEvent)
                    
                } else {
                    
                    if response.statusCode == 401 {
                        
                        self.sendAction(.notAuthorized)
                    }
                    
                    completion(.failure(.unexpectedResponseStatus(response.statusCode)))
                    return
                }
                
                guard let localFileURL = localFileURL else {
                    
                    completion(.failure(.emptyResponseData))
                    return
                }
                
                do {
                    
                    let data = try Data(contentsOf: localFileURL)
                    
                    // store data in cache
                    if self.sessionCached.configuration.urlCache?.cachedResponse(for: request) == nil {
                        
                        self.sessionCached.configuration.urlCache?.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                    }
                    
                    completion(.success(data))
                    
                } catch {
                    
                    completion(.failure(.corruptedData(error)))
                }
                
            }.resume()
            
        } catch {
            
            completion(.failure(ServerAgentError.requestCreationError(error)))
        }
    }
}

// MARK: - Execute Upload Command

extension ServerAgent {
    
    public func executeUploadCommand<Command>(
        command: Command,
        completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void
    ) where Command : ServerUploadCommand {
        
        do {
            
            let request = try uploadRequest(with: command)
            logMessage("upload request: \(request)")
            session.uploadTask(with: request, from: request.httpBody) { [unowned self] data, response, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    
                    completion(.failure(.emptyResponse))
                    return
                }
                
                if response.statusCode == 200 {
                    
                    self.sendAction(.networkActivityEvent)
                    
                } else {
                    
                    if response.statusCode == 401 {
                        
                        self.sendAction(.notAuthorized)
                    }
                    
                    completion(.failure(.unexpectedResponseStatus(response.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.emptyResponseData))
                    return
                }
                
                do {
                    
                    let response = try decoder.decode(Command.Response.self, from: data)
                    completion(.success(response))
                    
                } catch {
                    
                    completion(.failure(.corruptedData(error)))
                }
                
            }.resume()
            
        } catch {
            
            completion(.failure(ServerAgentError.requestCreationError(error)))
        }
    }
}

// MARK: - Request

internal extension ServerAgent {
    
    // TODO: tests
    func request<Command>(with command: Command) throws -> URLRequest where Command : ServerCommand {
        
        let url = try url(with: command.endpoint)
        
        var request = URLRequest(url: url)
        
        // http method
        request.httpMethod = command.method.rawValue
        
        // cookies headers
        request.httpShouldHandleCookies = false
        if command.cookiesProvider == false, let cookies = self.cookies {
            
            request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        
        // headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // token
        if command.cookiesProvider == false {
            
            request.setValue(command.token, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // parameters
        if let parameters = command.parameters, parameters.isEmpty == false {
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = parameters.map{ URLQueryItem(name: $0.name, value: $0.value) }
            
            guard let updatedURL = urlComponents?.url else {
                throw ServerRequestCreationError.unableConstructURLWithParameters
            }
            
            request.url = updatedURL
        }
        
        // body
        if let payload = command.payload {
            
            do {
                
                request.httpBody = try encoder.encode(payload)
                
            } catch {
                
                throw ServerRequestCreationError.unableEncodePayload(error)
            }
        }
        
        // timeout
        if let timeout = command.timeout {
            
            request.timeoutInterval = timeout
        }
        
        return request
    }
    
    // TODO: tests
    func downloadRequest<Command>(with command: Command) throws -> URLRequest where Command : ServerDownloadCommand {
        
        let url = try url(with: command.endpoint)
        
        var request = URLRequest(url: url)
        
        // cookies headers
        request.httpShouldHandleCookies = false
        if let cookies = self.cookies {
            
            request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        
        // headers
        request.httpMethod = command.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // token
        request.setValue(command.token, forHTTPHeaderField: "X-XSRF-TOKEN")
        
        // parameters
        if let parameters = command.parameters, parameters.isEmpty == false {
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = parameters.map{ URLQueryItem(name: $0.name, value: $0.value) }
            
            guard let updatedURL = urlComponents?.url else {
                throw ServerRequestCreationError.unableConstructURLWithParameters
            }
            
            request.url = updatedURL
        }
        
        // body
        if let payload = command.payload {
            
            do {
                
                request.httpBody = try encoder.encode(payload)
                
            } catch {
                
                throw ServerRequestCreationError.unableEncodePayload(error)
            }
        }
        
        // timeout
        if let timeout = command.timeout {
            
            request.timeoutInterval = timeout
        }
        
        // cache policy
        request.cachePolicy = command.cachePolicy
        
        return request
    }
    
    func uploadRequest<Command>(with command: Command) throws -> URLRequest where Command : ServerUploadCommand {
        
        let url = try url(with: command.endpoint)
        
        var request = URLRequest(url: url)
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        // cookies headers
        request.httpShouldHandleCookies = false
        if let cookies = self.cookies {
            
            request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        
        // headers
        request.httpMethod = command.method.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // token
        request.setValue(command.token, forHTTPHeaderField: "X-XSRF-TOKEN")
        
        // parameters
        if let parameters = command.parameters, parameters.isEmpty == false {
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = parameters.map{ URLQueryItem(name: $0.name, value: $0.value) }
            
            guard let updatedURL = urlComponents?.url else {
                throw ServerRequestCreationError.unableConstructURLWithParameters
            }
            
            request.url = updatedURL
        }
        
        // body
        
        var data = Data()
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(command.media.fileName)\"\r\n")
        data.append("Content-Type: \(command.media.mimeType)\r\n")
        data.append("\r\n")
        data.append(command.media.data)
        data.append("\r\n")
        data.append("--\(boundary)--\r\n")
        request.httpBody = data
        
        request.addValue(String(data.count), forHTTPHeaderField: "Content-Length")
        
        // timeout
        if let timeout = command.timeout {
            
            request.timeoutInterval = timeout
        }
        
        return request
    }
    
    // TODO: tests
    func url(with endpoint: String) throws -> URL {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw ServerRequestCreationError.unableConstructURL
        }
        
        return url
    }
}

// MARK: - URLSessionTaskDelegate

extension ServerAgent: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
        let message = error.map { " with error: \($0.localizedDescription)" } ?? ""
        
        logError("URL Session did become invalid\(message)")
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let message = error.map { "with error: \($0.localizedDescription)" } ?? "unexpected"
        
        logError("URLSessionTask: \(String(describing: task.originalRequest?.url)) did complete \(message)")
    }
}

private extension Data {
    
    // TODO: make throwing
    mutating func append(_ string: String) {
        
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        self.append(data)
    }
}
