//
//  File.swift
//  Vortex
//
//  Created by Valentin Ozerov on 19.02.2025.
//

import SwiftUI
import ButtonWithSheet
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

final class CollateralLoanLandingFactory {
    
    let model: Model
    
    init(
        model: Model
    ) {
        self.model = model
    }
    
    func makeOperationDetailButton() -> (CollateralLandingApplicationSaveConsentsResult) -> some View {
        
        return makeButton
        
        func makeButton(payload: PaymentID) -> some View {
            
            let buttonLabel = { self.makeSuccessButtonLabel(option: .details) }
            
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
                    merchantLogoMD5Hash: nil,
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

extension CollateralLoanLandingFactory {
    
    typealias Payload = CollateralLandingApplicationSaveConsentsResult
}
