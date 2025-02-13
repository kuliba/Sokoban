//
//  ResponseMapper+mapGetConsentsResponse.swift
//
//
//  Created by Valentin Ozerov on 18.11.2024.
//

import Foundation
import RemoteServices
import PDFKit

public extension ResponseMapper {
    
    static func mapGetConsentsResponse(
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
