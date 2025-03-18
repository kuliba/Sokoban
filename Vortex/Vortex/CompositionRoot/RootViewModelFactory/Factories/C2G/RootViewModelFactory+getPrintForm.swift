//
//  RootViewModelFactory+getPrintForm.swift
//  Vortex
//
//  Created by Igor Malyarov on 17.03.2025.
//

import Foundation
import PDFKit

extension RootViewModelFactory {
    
    @inlinable
    func getPrintForm(
        paymentOperationDetailID: Int,
        printFormType: String,
        completion: @escaping (Result<PDFDocument, Error>) -> Void
    ) {
        let getPrintForm = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetPrintFormRequest(printFormType: printFormType),
            mapResponse: ResponseMapper.mapGetPrintFormResponse
        )
        
        getPrintForm(.init(paymentOperationDetailID)) {
            
            guard case let .success(data) = $0,
                  let pdf = PDFDocument(data: data)
            else { return completion(.failure(PDFDocumentFailure())) }
            
            completion(.success(pdf))
            _ = getPrintForm
        }
    }
    
    struct PDFDocumentFailure: Error {}
}
