//
//  RootViewModelFactory+logging.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.10.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func infoNetworkLog(
        message: String,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        
        self.logger.log(level: .info, category: .network, message: message, file: file, line: line)
    }
}
