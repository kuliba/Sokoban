//
//  ResponseMapper+mapGetPrintFormForSavingsAccountResponse.swift
//
//
//  Created by Andryusina Nataly on 24.02.2025.
//

import Foundation
import RemoteServices
import PDFKit

public extension ResponseMapper {
    
    static func mapGetPrintFormForSavingsAccountResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<PDFDocument> {

        if let pdfDocument = PDFDocument(data: data) {
            
            return .success(pdfDocument)
        }
        
        return map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: Int
    ) throws -> PDFDocument {

        throw NSError(domain: "PDF document download error", code: -1)
    }
}
