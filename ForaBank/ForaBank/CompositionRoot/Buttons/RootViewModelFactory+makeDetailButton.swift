//
//  RootViewModelFactory+makeOperationDetailButton.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.11.2023.
//

import ButtonWithSheet
import Fetcher
import Foundation
import GenericRemoteService
import SwiftUI
import Tagged

typealias DocumentID = Tagged<_DocumentID, String>
enum _DocumentID {}

extension RootViewModelFactory {
    
    typealias DetailResult = Result<OperationDetailData, DetailError>
    
    static func makeOperationDetailButton(
        httpClient: HTTPClient,
        model: Model
    ) -> (DocumentID) -> some View {
        
        return makeButton
        
        func makeButton(documentID: DocumentID) -> some View {
            
            let getDetailService = RemoteService(
                createRequest: RequestFactory.createGetOperationDetailByPaymentIDRequest,
                performRequest: httpClient.performRequest(_:completion:),
                mapResponse: ResponseMapper.mapOperationDetailByPaymentIDResponse
            )
            
            let adapted = FetchAdapter(
                fetch: getDetailService.fetch(_:completion:),
                mapError: DetailError.init
            )
            
            let getSheetState = { completion in
                
                adapted.fetch(documentID, completion: completion)
            }
            
            @ViewBuilder
            func makeSheetStateView(
                result: DetailResult,
                dismiss: @escaping () -> Void
            ) -> some View {
                
                switch result {
                    
                case let .failure(error):
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                    
                case let .success(data):
                    let viewModel = OperationDetailInfoViewModel(
                        model: model,
                        operation: data,
                        dismissAction: dismiss
                    )
                    OperationDetailInfoView(viewModel: viewModel)
                }
            }
            
            return ButtonWithSheet(
                label: { Text("TBD") },
                getSheetState: getSheetState,
                makeSheetStateView: makeSheetStateView
            )
        }
    }
    
    #warning("finish with DetailError and extension below")
    struct DetailError: Error {}
}

private extension RootViewModelFactory.DetailError {
    
    init(
        _ error: MappingRemoteServiceError<ResponseMapper.OperationDetailByPaymentIDError>
    ) {
        self.init()
    }
}
