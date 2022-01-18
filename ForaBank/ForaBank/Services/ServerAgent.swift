//
//  ServerAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.12.2021.
//

import Foundation

class ServerAgent: ServerAgentProtocol {

    private let context: Context
    private var baseURL: String { context.env.baseURL }
    
    internal init(context: Context) {
        
        self.context = context
    }
    
    func executeCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerCommand {
        
        do {
            
            let request = try request(with: command)
            context.session.dataTask(with: request) {[unowned self] data, _, error in
                
                if let error = error {
                    
                    completion(.failure(.sessionError(error)))
                    return
                }
                
                guard let data = data else {
                    
                    completion(.failure(.emptyResponseData))
                    return
                }
                
                do {
                    
                    let response = try context.decoder.decode(Command.Response.self, from: data)
                    completion(.success(response))
                    
                } catch {
                    
                    completion(.failure(.curruptedData(error)))
                }
     
            }.resume()
            
        } catch {
            
            completion(.failure(ServerAgentError.requestCreationError(error)))
        }
    }
    
    internal func request<Command>(with command: Command) throws -> URLRequest where Command : ServerCommand {
        
        guard let url = URL(string: baseURL + command.endpoint) else {
            throw ServerRequestCreationError.unableConstructURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = command.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // token
        request.setValue(command.token, forHTTPHeaderField: "X-XSRF-TOKEN")
        
        // parameters
        if let parameters = command.parameters, parameters.isEmpty == false {
            
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = parameters.map{ URLQueryItem(name: $0.name, value: $0.value) }
            
            guard let updatedURL = urlComponents?.url else {
                throw ServerRequestCreationError.unableCounstructURLWithParameters
            }
            
            request.url = updatedURL
        }
        
        // body
        if let payload = command.payload {
            
            do {
                
                request.httpBody = try context.encoder.encode(payload)
                
            } catch {
                
                throw ServerRequestCreationError.unableEncodePayload(error)
            }
        }
        
        return request
    }
}

//MARK: - Context

extension ServerAgent {
    
    class Context {
        
        let env: Environment
        let session: URLSession
        let encoder: JSONEncoder
        let decoder: JSONDecoder
        
        init(for env: Environment) {
            
            self.env = env
            self.session = URLSession.shared
            self.encoder = JSONEncoder()
            self.decoder = JSONDecoder()
        }
    }
    
    enum Environment {
        
        case test
        case prod
        
        var baseURL: String {
            
            switch self {
            case .test:
                return "git.briginvest.ru/dbo/api/v3"
            case .prod:
                return "bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b"
            }
        }
    }
}
