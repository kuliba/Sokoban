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
        httpClient: HTTPClient
    ) -> (DocumentID) -> some View {
        
        return makeButton
        
        func makeButton(documentID: DocumentID) -> some View {
            
            let buttonLabel = { makeSuccessButtonLabel(option: .document) }
            
            let getDetailService = RemoteService(
                createRequest: RequestFactory.createGetPrintFormRequest,
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

private struct PDFDocumentWrapperView: View {
    
    @State private var isShowingSheet = false
    
    let pdfDocument: PDFDocument
    let dismissAction: () -> Void
    
    var body: some View {
        
        VStack {
            
            PDFDocumentView(document: pdfDocument)
            
            ButtonSimpleView(viewModel: .saveAndShare {
                
                isShowingSheet = true
            })
            .frame(height: 48)
            .padding()
        }
        .sheet(isPresented: $isShowingSheet) {
            
            ActivityView(
                viewModel: .init(
                    activityItems: [pdfDocument.dataRepresentation() as Any]
                )
            )
        }
    }
}

private extension ButtonSimpleView.ViewModel {
    
    static func saveAndShare(
        action: @escaping () -> Void
    ) ->  ButtonSimpleView.ViewModel {
        
        .init(
            title: "Сохранить или отправить",
            style: .red,
            action: action
        )
    }
}
