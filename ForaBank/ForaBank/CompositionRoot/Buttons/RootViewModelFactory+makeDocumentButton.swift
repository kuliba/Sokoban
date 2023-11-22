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
import SwiftUI
import Tagged

typealias DocumentID = Tagged<_DocumentID, Int>
enum _DocumentID {}

extension RootViewModelFactory {
    
    #warning("PDF???")
    typealias DocumentResult = Result<Data, DocumentError>
    
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
                mapError: DocumentError.init
            )
            
            let getSheetState = { completion in
                
                adapted.fetch(documentID, completion: completion)
            }
            
            @ViewBuilder
            func makeSheetStateView(
                result: DocumentResult,
                dismiss: @escaping () -> Void
            ) -> some View {
                
                switch result {
                    
                case let .failure(error):
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                    
                case let .success(data):
                    #warning("CHANGE TO PRINTFORM")
                    Text("\(data.count)")
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

private extension RootViewModelFactory.DocumentError {
    
    init(
        _ error: MappingRemoteServiceError<ResponseMapper.GetPrintFormError>
    ) {
        self.init()
    }
}
