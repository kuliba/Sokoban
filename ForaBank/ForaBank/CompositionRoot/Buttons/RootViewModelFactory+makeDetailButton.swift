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

typealias PaymentID = Tagged<_PaymentID, String>
enum _PaymentID {}

extension RootViewModelFactory {
    
    static func makeOperationDetailButton(
        httpClient: HTTPClient,
        model: Model
    ) -> (PaymentID) -> some View {
        
        return makeButton
        
        func makeButton(paymentID: PaymentID) -> some View {
            
            let buttonLabel = { makeSuccessButtonLabel(option: .details) }

            // TODO: reuse methods form `AnywayPayment`
            let getDetailService = RemoteService(
                createRequest: RequestFactory.createGetOperationDetailByPaymentIDRequest,
                performRequest: httpClient.performRequest(_:completion:),
                mapResponse: ResponseMapper.mapOperationDetailByPaymentIDResponse
            )
            
            typealias Completion = (OperationDetailData?) -> Void
            
            func getValue(completion: @escaping Completion) {
                
                getDetailService.fetch(paymentID) { result in
                    
                    switch result {
                    case .failure:
                        completion(nil)
                        
                    case let .success(detail):
                        completion(detail)
                    }
                }
            }
            
            @ViewBuilder
            func makeDetailView(
                detail: OperationDetailData,
                dismiss: @escaping () -> Void
            ) -> some View {
                
                let viewModel = OperationDetailInfoViewModel(
                    model: model,
                    operation: detail,
                    dismissAction: dismiss
                )
                OperationDetailInfoView(viewModel: viewModel)
            }
            
            return MagicButtonWithSheet(
                buttonLabel: buttonLabel,
                getValue: getValue,
                makeValueView: makeDetailView
            )
        }
    }
}
