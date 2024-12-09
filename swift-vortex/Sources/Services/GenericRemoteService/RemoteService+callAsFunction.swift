//
//  RemoteService+callAsFunction.swift
//
//
//  Created by Igor Malyarov on 16.05.2024.
//

public extension RemoteService {
    
    /// Processes the input and delivers the result using a completion handler.
    ///
    /// This method allows the `RemoteService` instance to be called as a function, processing the input and calling the provided completion handler with the result. This captures a strong reference to `self` within the closure, ensuring that the `RemoteService` instance is retained during the execution of the `process` method.
    ///
    /// Example usage:
    /// ```
    /// let remoteService = RemoteService(
    ///     createRequest: { input in
    ///         // Implementation of createRequest
    ///         return .success(URLRequest(url: URL(string: "https://example.com")!))
    ///     },
    ///     performRequest: { request, completion in
    ///         // Implementation of performRequest
    ///         completion(.success((Data(), HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)))
    ///     },
    ///     mapResponse: { response in
    ///         // Implementation of mapResponse
    ///         return .success("Output")
    ///     }
    /// )
    ///
    /// remoteService(input: ()) { result in
    ///     switch result {
    ///     case .success(let output):
    ///         print("Success: \(output)")
    ///     case .failure(let error):
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - input: The input value to be processed.
    ///   - completion: A closure to be executed once the processing is complete. The closure takes a single argument, which is a `Result` containing either the output value or an error.
    func callAsFunction(
        _ input: Input,
        completion: @escaping ProcessCompletion
    ) {
        process(input) { [self] result in
            
            completion(result)
            _ = self
        }
    }
    
    /// Processes the input and returns the result asynchronously.
    ///
    /// This method allows the `RemoteService` instance to be called as a function in an asynchronous context, processing the input and returning the output or throwing an error. This ensures that the `RemoteService` instance is retained during the execution of the `process` method.
    ///
    /// Example usage:
    /// ```
    /// Task {
    ///     do {
    ///         let remoteService = RemoteService(
    ///             createRequest: { input in
    ///                 // Implementation of createRequest
    ///                 return .success(URLRequest(url: URL(string: "https://example.com")!))
    ///             },
    ///             performRequest: { request, completion in
    ///                 // Implementation of performRequest
    ///                 completion(.success((Data(), HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)))
    ///             },
    ///             mapResponse: { response in
    ///                 // Implementation of mapResponse
    ///                 return .success("Output")
    ///             }
    ///         )
    ///
    ///         let output = try await remoteService(input: ())
    ///         print("Success: \(output)")
    ///     } catch {
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    ///
    ///    /// - Parameter input: The input value to be processed.
    /// - Returns: The output value.
    /// - Throws: An error if the processing fails.
    func callAsFunction(_ input: Input) async throws -> Output {
        
        return try await process(input)
    }
}
