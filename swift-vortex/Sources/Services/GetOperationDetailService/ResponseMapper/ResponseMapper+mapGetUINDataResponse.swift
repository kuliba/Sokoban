//
//  ResponseMapper+mapGetOperationDetailResponse.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetOperationDetailResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetOperationDetailResponse> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
}

private extension ResponseMapper {
    
    static func map(
        _ data: _DTO
    ) throws -> GetOperationDetailResponse {
        
        try data.response
    }
    
    struct _DTO: Decodable {
        
        let account: String?
        let accountTitle: String?
        let amount: Decimal?
        let billDate: String?
        let billNumber: String?
        let cityName: String?
        let claimId: String?
        let comment: String?
        let countryName: String?
        let currencyAmount: String?
        let currencyRate: Int?
        let cursiveAmount: String?
        let cursivePayeeAmount: String?
        let cursivePayerAmount: String?
        let dateForDetail: String?
        let depositDateOpen: String?
        let depositNumber: String?
        let division: String?
        let driverLicense: String?
        let externalTransferType: String?
        let isForaBank: Bool?
        let isTrafficPoliceService: Bool?
        let MCC: String?
        let memberId: String?
        let merchantIcon: String?
        let merchantSubName: String?
        let OKTMO: String?
        let operation: String?
        let operationStatus: String?
        let payeeAccountId: Int?
        let payeeAccountNumber: String?
        let payeeAmount: Int?
        let payeeBankBIC: String?
        let payeeBankCorrAccount: String?
        let payeeBankName: String?
        let payeeCardId: Int?
        let payeeCardNumber: String?
        let payeeCheckAccount: String?
        let payeeCurrency: String?
        let payeeFirstName: String?
        let payeeFullName: String?
        let payeeINN: String?
        let payeeKPP: String?
        let payeeMiddleName: String?
        let payeePhone: String?
        let payeeSurName: String?
        let payerAccountId: Int?
        let payerAccountNumber: String?
        let payerAddress: String?
        let payerAmount: Int?
        let payerCardId: Int?
        let payerCardNumber: String?
        let payerCurrency: String?
        let payerDocument: String?
        let payerFee: Int?
        let payerFirstName: String?
        let payerFullName: String?
        let payerINN: String?
        let payerMiddleName: String?
        let payerPhone: String?
        let payerSurName: String?
        let paymentMethod: String?
        let paymentOperationDetailId: Int?
        let paymentTemplateId: Int?
        let period: String?
        let printFormType: String?
        let provider: String?
        let puref: String?
        let regCert: String?
        let requestDate: String?
        let responseDate: String?
        let returned: Bool?
        let serviceName: String?
        let serviceSelect: String?
        let shopLink: String?
        let transferDate: String?
        let transferEnum: String?
        let transferNumber: String?
        let transferReference: String?
        let trnPickupPointName: String?
    }
}

private extension ResponseMapper._DTO {
    
    var response: ResponseMapper.GetOperationDetailResponse {
        
        get throws {
            
            guard let claimId else { throw MissingMandatoryFields() }

            return .init(
                account: account,
                accountTitle: accountTitle,
                amount: amount,
                billDate: billDate,
                billNumber: billNumber,
                cityName: cityName,
                claimID: claimId,
                comment: comment,
                countryName: countryName,
                currencyAmount: currencyAmount,
                currencyRate: currencyRate,
                cursiveAmount: cursiveAmount,
                cursivePayeeAmount: cursivePayeeAmount,
                cursivePayerAmount: cursivePayerAmount,
                dateForDetail: dateForDetail,
                depositDateOpen: depositDateOpen,
                depositNumber: depositNumber,
                division: division,
                driverLicense: driverLicense,
                externalTransferType: externalTransferType,
                isForaBank: isForaBank,
                isTrafficPoliceService: isTrafficPoliceService,
                MCC: MCC,
                memberID: memberId,
                merchantIcon: merchantIcon,
                merchantSubName: merchantSubName,
                OKTMO: OKTMO,
                operation: operation,
                operationStatus: operationStatus,
                payeeAccountID: payeeAccountId,
                payeeAccountNumber: payeeAccountNumber,
                payeeAmount: payeeAmount,
                payeeBankBIC: payeeBankBIC,
                payeeBankCorrAccount: payeeBankCorrAccount,
                payeeBankName: payeeBankName,
                payeeCardID: payeeCardId,
                payeeCardNumber: payeeCardNumber,
                payeeCheckAccount: payeeCheckAccount,
                payeeCurrency: payeeCurrency,
                payeeFirstName: payeeFirstName,
                payeeFullName: payeeFullName,
                payeeINN: payeeINN,
                payeeKPP: payeeKPP,
                payeeMiddleName: payeeMiddleName,
                payeePhone: payeePhone,
                payeeSurName: payeeSurName,
                payerAccountID: payerAccountId,
                payerAccountNumber: payerAccountNumber,
                payerAddress: payerAddress,
                payerAmount: payerAmount,
                payerCardID: payerCardId,
                payerCardNumber: payerCardNumber,
                payerCurrency: payerCurrency,
                payerDocument: payerDocument,
                payerFee: payerFee,
                payerFirstName: payerFirstName,
                payerFullName: payerFullName,
                payerINN: payerINN,
                payerMiddleName: payerMiddleName,
                payerPhone: payerPhone,
                payerSurName: payerSurName,
                paymentMethod: paymentMethod,
                paymentOperationDetailID: paymentOperationDetailId,
                paymentTemplateID: paymentTemplateId,
                period: period,
                printFormType: printFormType,
                provider: provider,
                puref: puref,
                regCert: regCert,
                requestDate: requestDate,
                responseDate: responseDate,
                returned: returned,
                serviceName: serviceName,
                serviceSelect: serviceSelect,
                shopLink: shopLink,
                transferDate: transferDate,
                transferEnum: transferEnum,
                transferNumber: transferNumber,
                transferReference: transferReference,
                trnPickupPointName: trnPickupPointName
            )
        }
    }
    
    struct MissingMandatoryFields: Error {}
}

