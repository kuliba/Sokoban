//
//  String+Extension.swift
//  VortexTests
//
//  Created by Igor Malyarov on 24.02.2023.
//

@testable import ForaBank
import Foundation

extension String {
    
    static let operatorData_iVortex4285: Self = serial(for: .iVortex4285)
    static let operatorData_iVortex4286: Self = serial(for: .iVortex4286)
    static let operatorData_iVortex515A3: Self = serial(for: .iVortex515A3)
    
    typealias OperatorData = OperatorGroupData.OperatorData
    
    private static func serial(for operatorData: OperatorData) -> String {
        
        String(data: try! JSONEncoder().encode(operatorData), encoding: .utf8)!
    }
}
