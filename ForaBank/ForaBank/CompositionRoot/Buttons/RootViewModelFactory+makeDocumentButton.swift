//
//  RootViewModelFactory+makeDocumentButton.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2023.
//

import ButtonWithSheet
import Fetcher
import Foundation
import GenericRemoteService
import PDFKit
import SwiftUI
import Tagged

typealias DocumentID = Tagged<_DocumentID, Int>
enum _DocumentID {}

extension RootViewModelFactory {
    
    typealias GetPrintFormServiceError = MappingRemoteServiceError<ResponseMapper.GetPrintFormError>
    typealias GetPrintFormServiceResult = Result<Data, GetPrintFormServiceError>
    typealias PDFResult = Result<PDFDocument, DocumentError>
    
    static func makeDocumentButton(
        httpClient: HTTPClient,
        model: Model
    ) -> (DocumentID) -> some View {
        
        return makeButton
        
        func makeButton(documentID: DocumentID) -> some View {
            
            let getDetailService = RemoteService(
                createRequest: RequestFactory.createGetPrintFormRequest,
                performRequest: httpClient.performRequest(_:completion:),
                mapResponse: ResponseMapper.mapGetPrintFormResponse
            )
            
            let adapted = FetchAdapter(
                fetch: getDetailService.fetch(_:completion:),
                mapResult: PDFResult.init
            )
            
            let getSheetState = { completion in
                
                adapted.fetch(documentID, completion: completion)
            }
            
            @ViewBuilder
            func makeSheetStateView(
                result: PDFResult,
                dismiss: @escaping () -> Void
            ) -> some View {
                
                switch result {
                    
                case let .failure(error):
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                    
                case let .success(pdfDocument):
#warning("CHANGE TO PRINTFORM")
                    Text("TBD: \(pdfDocument)")
                }
            }
            
            return ButtonWithSheet(
                label: { Text("TBD") },
                getSheetState: getSheetState,
                makeSheetStateView: makeSheetStateView
            )
        }
    }
    
#warning("finish with DocumentError and extension below")
    struct DocumentError: Error {}
}

private extension RootViewModelFactory.PDFResult {
    
    init(_ result: RootViewModelFactory.GetPrintFormServiceResult) {
        
        switch result {
        case let .failure(error):
            self = .failure(RootViewModelFactory.DocumentError(error))
            
        case let .success(data):
            if let pdf = PDFDocument(data: data) {
                self = .success(pdf)
            } else {
                self = .failure(RootViewModelFactory.DocumentError())
                return
            }
        }
    }
}

private extension RootViewModelFactory.DocumentError {
    
    init(
        _ error: RootViewModelFactory.GetPrintFormServiceError
    ) {
        self.init()
    }
}
