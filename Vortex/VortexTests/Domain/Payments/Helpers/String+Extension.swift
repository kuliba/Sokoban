//
//  String+Extension.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.02.2023.
//

@testable import ForaBank
import Foundation

extension String {
    
    static let operatorData_iFora4285: Self = serial(for: .iFora4285)
    static let operatorData_iFora4286: Self = serial(for: .iFora4286)
    static let operatorData_iFora515A3: Self = serial(for: .iFora515A3)
    
    typealias OperatorData = OperatorGroupData.OperatorData
    
    private static func serial(for operatorData: OperatorData) -> String {
        
        String(data: try! JSONEncoder().encode(operatorData), encoding: .utf8)!
    }
}
