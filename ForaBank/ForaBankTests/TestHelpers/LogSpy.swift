//
//  LogSpy.swift
//  VortexTests
//
//  Created by Igor Malyarov on 12.11.2023.
//

@testable import ForaBank

final class LogSpy {
    
    private(set) var messages = [Message]()
    
    func log(
        _ level: LoggerAgentLevel,
        _ category: LoggerAgentCategory,
        _ text: String
    ) {
        messages.append(.init(level, category, text))
    }
    
    struct Message: Equatable {
        
        let level: LoggerAgentLevel
        let category: LoggerAgentCategory
        let text: String
        
        init(
            _ level: LoggerAgentLevel,
            _ category: LoggerAgentCategory,
            _ text: String
        ) {
            self.level = level
            self.category = category
            self.text = text
        }
    }
}

extension LogSpy {
    
    func log(_ level: LoggerAgentLevel, _ message: String) {
        
        self.log(level, .cache, message)
    }
}

extension LogSpy {
    
    func log(_ message: String) {
        
        log(.debug, .cache, message)
    }
}
