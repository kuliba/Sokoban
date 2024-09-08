//
//  Logger+decorate.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.09.2024.
//

import Foundation

extension LoggerAgentProtocol {
    
    func decorate<T>(
        _ f: @escaping () throws -> T,
        with category: LoggerAgentCategory,
        file: StaticString = #file,
        line: UInt = #line
    ) -> () throws -> T {
        
        return {
            
            do {
                let t = try f()
                self.log(level: .info, category: category, message: "=== " + String(describing: t), file: file, line: line)
                return t
            } catch {
                self.log(level: .error, category: category, message: "=== " + String(describing: error), file: file, line: line)
                throw error
            }
        }
    }
    
    @_disfavoredOverload
    func decorate<T, V>(
        _ f: @escaping (V) throws -> T,
        with category: LoggerAgentCategory,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (V) throws -> T {
        
        return { v in
            
            do {
                let t = try f(v)
                self.log(level: .info, category: category, message: "=== " + String(describing: t), file: file, line: line)
                return t
            } catch {
                self.log(level: .error, category: category, message: "=== " + String(describing: error), file: file, line: line)
                throw error
            }
        }
    }
    
    func decorate<T, V, E: Error>(
        f: @escaping (V) -> Result<T, E>,
        with category: LoggerAgentCategory,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (V) -> Result<T, E> {
        
        return {
            
            switch f($0) {
            case let .failure(failure):
                self.log(level: .error, category: category, message: "=== " + String(describing: failure), file: file, line: line)
                return(.failure(failure))
                
            case let .success(t):
                self.log(level: .info, category: category, message: "=== " + String(describing: t), file: file, line: line)
                return .success(t)
            }
        }
    }
}
