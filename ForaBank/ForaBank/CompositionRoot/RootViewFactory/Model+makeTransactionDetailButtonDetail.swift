//
//  Model+makeTransactionDetailButtonDetail.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.06.2024.
//

import AnywayPaymentBackend
import Foundation
import RemoteServices

extension Model {
    
    func makeTransactionDetailButtonDetail(
        with info: _OperationInfo
    ) -> TransactionDetailButton.Details? {
        
        info.operationDetail.map(makeTransactionDetailButtonDetail)
    }
    
    func makeTransactionDetailButtonDetail(
        with operation: OperationDetailData
    ) -> TransactionDetailButton.Details {
        
        let viewModel = OperationDetailInfoViewModel(
            model: self,
            operation: operation,
            dismissAction: {}
        )
        
        return.init(logo: viewModel.logo, cells: viewModel.cells)
    }
}

extension _OperationInfo {
    
    var operationDetail: OperationDetailData? {
        
        response?.operationDetail
    }
    
    private var response: Response? {
        
        guard case let .details(details) = self
        else { return nil }
        
        return details.response
    }
    
    typealias Response = RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse
}

// MARK: - Adapters

private extension RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse {
    
    var operationDetail: OperationDetailData {
        
        return .init(
            oktmo: oktmo,
            account: account,
            accountTitle: accountTitle,
            amount: NSDecimalNumber(decimal: amount).doubleValue,
            billDate: billDate,
            billNumber: billNumber,
            claimId: claimID,
            comment: comment,
            countryName: countryName,
            currencyAmount: currencyAmount,
            dateForDetail: dateForDetail,
            division: division,
            driverLicense: driverLicense,
            externalTransferType: _externalTransferType,
            isForaBank: isForaBank,
            isTrafficPoliceService: isTrafficPoliceService,
            memberId: memberID,
            operation: operation,
            payeeAccountId: payeeAccountID,
            payeeAccountNumber: payeeAccountNumber,
            payeeAmount: payeeAmount.map { NSDecimalNumber(decimal: $0).doubleValue },
            payeeBankBIC: payeeBankBIC,
            payeeBankCorrAccount: payeeBankCorrAccount,
            payeeBankName: payeeBankName,
            payeeCardId: payeeCardID,
            payeeCardNumber: payeeCardNumber,
            payeeCurrency: payeeCurrency,
            payeeFirstName: payeeFirstName,
            payeeFullName: payeeFullName,
            payeeINN: payeeINN,
            payeeKPP: payeeKPP,
            payeeMiddleName: payeeMiddleName,
            payeePhone: payeePhone,
            payeeSurName: payeeSurName,
            payerAccountId: payerAccountID,
            payerAccountNumber: payerAccountNumber,
            payerAddress: payerAddress,
            payerAmount: NSDecimalNumber(decimal: payerAmount).doubleValue,
            payerCardId: payerCardID,
            payerCardNumber: payerCardNumber,
            payerCurrency: payerCurrency,
            payerDocument: payerDocument,
            payerFee: NSDecimalNumber(decimal: payerFee).doubleValue,
            payerFirstName: payerFirstName,
            payerFullName: payerFullName,
            payerINN: payerINN,
            payerMiddleName: payerMiddleName,
            payerPhone: payerPhone,
            payerSurName: payerSurName,
            paymentOperationDetailId: paymentOperationDetailID,
            paymentTemplateId: paymentTemplateID,
            period: period,
            printFormType: _printFormType,
            provider: provider,
            puref: puref,
            regCert: regCert,
            requestDate: requestDate,
            responseDate: responseDate,
            returned: returned,
            transferDate: transferDate,
            transferEnum: _transferEnum,
            transferNumber: transferNumber,
            transferReference: transferReference,
            cursivePayerAmount: cursivePayerAmount,
            cursivePayeeAmount: cursivePayeeAmount,
            cursiveAmount: cursiveAmount,
            serviceSelect: serviceSelect,
            serviceName: serviceName,
            merchantSubName: merchantSubName,
            merchantIcon: merchantIcon,
            operationStatus: _operationStatus,
            shopLink: shopLink,
            payeeCheckAccount: payeeCheckAccount,
            depositNumber: depositNumber,
            depositDateOpen: depositDateOpen,
            currencyRate: currencyRate.map { NSDecimalNumber(decimal: $0).doubleValue },
            mcc: mcc,
            printData: _printData,
            paymentMethod: _paymentMethod
        )
    }
    
    private var _externalTransferType: OperationDetailData.ExternalTransferType? {
        
        switch externalTransferType {
        case .none:   return .none
        case .entity: return .entity
        case .individual: return .individual
        }
    }
    
    private var _operationStatus: OperationDetailData.OperationStatus? {
        
        switch operationStatus {
        case .none:       return .none
        case .complete:   return .complete
        case .inProgress: return .inProgress
        case .rejected:   return .rejected
        }
    }
    
    private var _printData: OperationDetailData.PrintMapData? {
        
        return nil
    }
    
    private var _printFormType: ForaBank.PrintFormType {
        
        switch printFormType {
        case .addressing_cash:           return .addressing_cash
        case .addressless:               return .addressless
        case .c2b:                       return .c2b
        case .changeOutgoing:            return .changeOutgoing
        case .closeAccount:              return .closeAccount
        case .closeDeposit:              return .closeDeposit
        case .contactAddressless:        return .contactAddressless
        case .direct:                    return .direct
        case .external:                  return .external
        case .housingAndCommunalService: return .housingAndCommunalService
        case .`internal`:                return .`internal`
        case .internet:                  return .internet
        case .mobile:                    return .mobile
        case .newDirect:                 return .newDirect
        case .returnOutgoing:            return .returnOutgoing
        case .sberQR:                    return .sberQR
        case .sbp:                       return .sbp
        case .sticker:                   return .sticker
        case .taxAndStateService:        return .taxAndStateService
        case .transport:                 return .transport
        }
    }
    
    private var _paymentMethod: OperationDetailData.PaymentMethod? {
        
        switch paymentMethod {
        case .none:     return .none
        case .cash:     return .cash
        case .cashless: return .cashless
        }
    }
    
    private var _transferEnum: OperationDetailData.TransferEnum? {
        
        switch transfer {
        case .none: return .none
        case let .some(a):
            switch a {
            case .accountClose:               return .accountClose
            case .accountToAccount:           return .accountToAccount
            case .accountToCard:              return .accountToCard
            case .accountToPhone:             return .accountToPhone
            case .bankDef:                    return .bankDef
            case .bestToPay:                  return .bestToPay
            case .c2bPayment:                 return .c2bPayment
            case .c2bQrData:                  return .c2bQrData
            case .cardToAccount:              return .cardToAccount
            case .cardToCard:                 return .cardToCard
            case .cardToPhone:                return .cardToPhone
            case .changeOutgoing:             return .changeOutgoing
            case .contactAddressing:          return .contactAddressing
            case .contactAddressingCash:      return .contactAddressingCash
            case .contactAddressless:         return .contactAddressless
            case .conversionAccountToAccount: return .conversionAccountToAccount
            case .conversionAccountToCard:    return .conversionAccountToCard
            case .conversionAccountToPhone:   return .conversionAccountToPhone
            case .conversionCardToAccount:    return .conversionCardToAccount
            case .conversionCardToCard:       return .conversionCardToCard
            case .conversionCardToPhone:      return .conversionCardToPhone
            case .depositClose:               return .depositClose
            case .depositOpen:                return .depositOpen
            case .direct:                     return .direct
            case .elecsnet:                   return .elecsnet
            case .external:                   return .external
            case .housingAndCommunalService:  return .housingAndCommunalService
            case .interestDeposit:            return .interestDeposit
            case .internal:                   return .internal
            case .internet:                   return .internet
            case .meToMeCredit:               return .meToMeCredit
            case .meToMeDebit:                return .meToMeDebit
            case .mobile:                     return .mobile
            case .other:                      return .other
            case .productPaymentCourier:      return .productPaymentCourier
            case .productPaymentOffice:       return .productPaymentOffice
            case .returnOutgoing:             return .returnOutgoing
            case .sberQRPayment:              return .sberQRPayment
            case .sfp:                        return .sfp
            case .taxAndStateService:         return .taxAndStateService
            case .transport:                  return .transport
            }
        }
    }
}
