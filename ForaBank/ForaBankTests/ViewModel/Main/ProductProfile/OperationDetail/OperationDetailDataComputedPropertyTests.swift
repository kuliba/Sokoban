//
//  OperationDetailDataComputedPropertyTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.12.2023.
//

@testable import ForaBank
import XCTest

final class OperationDetailDataComputedPropertyTests: XCTestCase {
    
    func test_init_sberQR() throws {
        
        let data = try XCTUnwrap(String.sberQRWithOperationDetailData.data(using: .utf8))
        let response = try JSONDecoder().decode(SberQRResponse.self, from: data)
    }
    
    // MARKL: - Helpers
    
    private struct SberQRResponse: Decodable {
        
        let statusCode: Int
        let errorMessage: String?
        let data: OperationDetailData?
    }
}

private extension String {
    
    static let sberQRWithOperationDetailData = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "claimId": "300161702887535276",
    "requestDate": "18.12.2023 11:19:11",
    "responseDate": "18.12.2023 11:19:14",
    "transferDate": "18.12.2023",
    "payerCardId": 10000282829,
    "payerCardNumber": "**** **** **28 7435",
    "payerAccountId": 10005054701,
    "payerAccountNumber": "40817810811005025164",
    "payerFullName": "Маляров Игорь Александрович",
    "payerAddress": "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 108803, Москва г, Воскресенское п, Воскресенское п,  д. 40,  корп. 2,  кв. 228",
    "payerAmount": 220,
    "cursivePayerAmount": null,
    "payerFee": 0,
    "payerCurrency": "RUB",
    "payeeFullName": "ООО Енотия_ЭквИФТ",
    "payeePhone": null,
    "payeeBankName": "Сбербанк",
    "payeeAmount": null,
    "cursivePayeeAmount": null,
    "payeeCurrency": null,
    "amount": 220,
    "cursiveAmount": null,
    "currencyAmount": null,
    "comment": null,
    "accountTitle": null,
    "account": null,
    "transferEnum": "SBER_QR_PAYMENT",
    "externalTransferType": null,
    "isForaBank": null,
    "transferReference": null,
    "payerSurName": null,
    "payerFirstName": "Игорь",
    "payerMiddleName": "Александрович",
    "payeeSurName": null,
    "payeeFirstName": null,
    "payeeMiddleName": null,
    "countryName": null,
    "cityName": null,
    "trnPickupPointName": null,
    "paymentMethod": null,
    "payerDocument": null,
    "period": null,
    "provider": null,
    "payerPhone": null,
    "transferNumber": null,
    "payeeBankCorrAccount": null,
    "payeeCardNumber": null,
    "payeeCardId": null,
    "payeeAccountNumber": null,
    "payeeAccountId": null,
    "operation": null,
    "puref": "0||PayQR",
    "memberId": "100000000111",
    "driverLicense": null,
    "regCert": null,
    "billNumber": null,
    "billDate": null,
    "isTrafficPoliceService": false,
    "division": null,
    "serviceSelect": null,
    "serviceName": null,
    "merchantSubName": "сббол енот_QR",
    "merchantIcon": "<>\\n",
    "operationStatus": "COMPLETE",
    "shopLink": null,
    "payeeCheckAccount": null,
    "depositNumber": null,
    "depositDateOpen": null,
    "currencyRate": null,
    "paymentOperationDetailId": 82212,
    "printFormType": "sberQR",
    "dateForDetail": "18 декабря 2023, 11:18",
    "paymentTemplateId": null,
    "returned": false,
    "payerINN": "773320037714",
    "payeeINN": "7715506197",
    "payeeKPP": null,
    "payeeBankBIC": null,
    "OKTMO": null,
    "MCC": null
  }
}
"""
}
