//
//  RootViewModelFactory+getSavingsAccountInfo.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.02.2025.
//

import Foundation
import RemoteServices
import SavingsAccount
import SavingsServices
import GenericRemoteService

extension RootViewModelFactory {
    
    @inlinable
    func getSavingsAccountInfo(
        product: ProductData,
        completion: @escaping (SavingsAccountDetailsState?) -> Void
    ) {
        guard let account = product.asAccount,
              account.isSavingAccount == true,
              let accountNumber = account.accountNumber
        else { return completion(nil) }
        
        let service = onBackground(
            makeRequest: RequestFactory.createGetSavingsAccountInfoRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetSavingsAccountInfoResponse
        )
        
        service(.init(accountNumber: accountNumber)) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                handleFailure(failure, completion: completion)
                
            case let .success(result):
                completion(.init(status: .result(result.details)))
            }
            _ = service
        }
    }
    
    func handleFailure(
        _ failure: Error,
        completion: @escaping (SavingsAccountDetailsState?) -> Void
    ) {
        switch failure {
        case let error as RemoteServiceError<Error, Error, RemoteServices.ResponseMapper.MappingError>:
            switch error {
            case .mapResponse:
                return completion(.init(status: .failure(.alert)))
                
            case let .performRequest(error):
                if error.isNotConnectedToInternetOrTimeout() {
                    return completion(.init(status: .failure(.informer)))
                } else {
                    return completion(.init(status: .failure(.alert)))
                }
                
            default:
                return completion(.init(status: .failure(.alert)))
            }
            
        default:
            break
        }
    }
}

// MARK: - Adapters

private extension GetSavingsAccountInfoResponse {
    
    var details: SavingsAccountDetails {
        
        let current: Double = Double(daysLeft ?? 0)
        let next: Double = Double(dateNext?.suffix(2) ?? "1") ?? 1
        let progress: Double = dateStart == dateNext ? 0 : 1 - current / next
        
        return .init(
            dateNext: dateNext,
            dateSettlement: dateSettlement,
            dateStart: dateStart,
            daysLeft: daysLeft,
            daysLeftText: daysLeftText,
            interestAmount: NSDecimalNumber(floatLiteral: interestAmount ?? 0).decimalValue,
            interestPaid: NSDecimalNumber(floatLiteral: interestPaid ?? 0).decimalValue,
            isNeedTopUp: isNeedTopUp,
            isPercentBurned: isPercentBurned,
            minRest: NSDecimalNumber(floatLiteral: minRest ?? 0).decimalValue,
            currencyCode: "RUB",
            progress: progress
        )
    }
}
