//
//  ResponseMapper+mapCollateralLoanLandingGetConsents.swift
//  
//
//  Created by Valentin Ozerov on 28.10.2024.
//

import Foundation
import RemoteServices
import PDFKit

public extension ResponseMapper {
    
    static func mapCollateralLoanLandingGetConsents(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<PDFDocument> {
        
        if let pdf = PDFDocument(data: data) {

            return .success(pdf)
        } else {
            
            return map(
                data, httpURLResponse,
                mapOrThrow: map
            )
        }
    }
    
    private static func map(
        _ data: Int
    ) throws -> PDFDocument {
        
        throw NSError(domain: "PDF document creation failed", code: -1)
    }
}
