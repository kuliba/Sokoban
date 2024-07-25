//
//  Model+QRHelpers.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.12.2023.
//

// MARK: - Reusable

extension Model {
    
    @_disfavoredOverload
    func operatorsFromQR(
        _ qr: QRCode,
        _ qrMapping: QRMapping
    ) -> [OperatorGroupData.OperatorData]? {
        
        guard let operatorsFromQr = dictionaryAnywayOperators(
            with: qr,
            mapping: qrMapping
        )
        else { return nil }
        
        let validQrOperators = dictionaryQRAnewayOperator()
        let operators = operatorsFromQr.filter {
        
            validQrOperators.contains($0) && !$0.parameterList.isEmpty
        }
     
        return operators
    }
}
