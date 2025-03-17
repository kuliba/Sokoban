//
//  XCTestCase+makeTestPDFDocument.swift
//  VortexTests
//
//  Created by Igor Malyarov on 17.03.2025.
//

import PDFKit
import XCTest

final class XCTestCase_makeTestPDFDocumentTests: XCTestCase {
    
    func test_makeTestPDFDocument_shouldNotThrow() throws {
        
        XCTAssertNoThrow(try makeMinimalTestPDFData())
    }
}

// TODO: move to factories
extension XCTestCase {
    
    /// Creates a minimal valid PDFDocument `data` for testing purposes.
    ///
    /// - Returns: A `PDFDocument` containing a single, empty 1x1 point page.
    ///
    /// - Warning:
    ///   - Two PDFs generated with this function **will not be byte-for-byte identical**.
    ///   - PDFs may contain metadata such as timestamps or internal structure variations.
    ///   - For equality testing, compare document properties (e.g., page count, dimensions) instead of raw data.
    func makeMinimalTestPDFData(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: 1, height: 1) // Smallest possible PDF
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
        }
        
        let pdf = try XCTUnwrap(PDFDocument(data: data), "Expected to have valid PDF, but got nil instead.", file: file, line: line)
        
        return data
    }
}
