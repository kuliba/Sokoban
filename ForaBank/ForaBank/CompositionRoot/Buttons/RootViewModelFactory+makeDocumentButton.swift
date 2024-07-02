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
    
    static func makeDocumentButton(
        httpClient: HTTPClient,
        printFormType: RequestFactory.PrintFormType
    ) -> (DocumentID) -> some View {
        
        return makeButton
        
        func makeButton(documentID: DocumentID) -> some View {
            
            let buttonLabel = { makeSuccessButtonLabel(option: .document) }
            
            let getDetailService = RemoteService(
                createRequest: RequestFactory.createGetPrintFormRequest(printFormType: printFormType),
                performRequest: httpClient.performRequest(_:completion:),
                mapResponse: ResponseMapper.mapGetPrintFormResponse
            )
            
            typealias Completion = (PDFDocument?) -> Void
            
            func getValue(completion: @escaping Completion) {
                
                getDetailService.fetch(documentID) { result in
                    
                    switch result {
                    case .failure:
                        completion(nil)
                        
                    case let .success(data):
                        completion(PDFDocument(data: data))
                    }
                }
            }
            
            @ViewBuilder
            func makePDFDocumentView(
                pdfDocument: PDFDocument,
                dismiss: @escaping () -> Void
            ) -> some View {
                
                PDFDocumentWrapperView(
                    pdfDocument: pdfDocument,
                    dismissAction: dismiss
                )
            }
            
            return MagicButtonWithSheet(
                buttonLabel: buttonLabel,
                getValue: getValue,
                makeValueView: makePDFDocumentView
            )
        }
    }
}
