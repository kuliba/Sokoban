//
//  OperationDetailDataComputedPropertyTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 18.12.2023.
//

@testable import Vortex
import XCTest

// TODO: move to prod after finishing up with tests after model decoupling
extension OperationDetailData {
    
    typealias CurrencyCode = String
    typealias FormatAmount = (Double, CurrencyCode) -> String?
    typealias IconType = OperationDetailInfoViewModel.IconType
    typealias BankCell = OperationDetailInfoViewModel.BankCellViewModel
    typealias PropertyCell = OperationDetailInfoViewModel.PropertyCellViewModel
    
    var payerProductId: Int? {
        
        [payerCardId, payerAccountId].compactMap { $0 }.first
    }
    
    var payerProductNumber: String? {
        
        [payerCardNumber, payerAccountNumber].compactMap {$0}.first
    }
    
    func balance(
        formatAmount: @escaping FormatAmount
    ) -> PropertyCell? {
        
        let amount = transferEnum == .external ? payerAmount - payerFee : payerAmount
        let formattedAmount = formatAmount(amount, payerCurrency)
        
        guard let formattedAmount = formattedAmount else {
            return nil
        }
        
        return .init(
            title: "Сумма перевода",
            iconType: IconType.balance.icon,
            value: formattedAmount)
    }
    
    func operationDate() -> PropertyCell? {
        
        switch transferEnum {
        case .depositClose:
            return .init(
                title: "Тип платежа",
                iconType: IconType.date.icon,
                value: "Закрытие вклада"
            )
        default:
            return .init(
                title: "Дата и время операции (МСК)",
                iconType: IconType.date.icon,
                value: responseDate
            )
        }
    }
    
    func operationDetailStatus() -> BankCell? {
        
        let title = "Статус операции"
        switch operationStatus {
            
        case .complete:
            return BankCell(
                title: title,
                icon: .init("OkOperators"),
                name: "Успешно")
            
        case .inProgress:
            return BankCell(
                title: title,
                icon: .init("waiting"),
                name: "В обработке")
            
        case .rejected:
            return BankCell(
                title: title,
                icon: .init("rejected"),
                name: "Отказ")
            
        case .unknown:
            return nil
            
        case .none:
            return nil
        }
    }
}

// TODO: move to prod after finishing up with tests after model decoupling
extension OperationDetailData {
    
    typealias DefaultCell = OperationDetailInfoViewModel.DefaultCellViewModel
    
    func sberQRPayment(
        formatAmount: @escaping FormatAmount
    ) -> [DefaultCell] {
        
        [balance(formatAmount: formatAmount),
         merchant,
         operationDate(),
         operationDetailStatus(),
        ].compactMap { $0 }
    }
}

final class OperationDetailDataComputedPropertyTests: XCTestCase {
    
    // MARK: - sberQRPayment
    
    // TODO: complete after splitting Model
    func test_sberQRPayment_shouldReturnViewModelsWithTitles() throws {
        
        try XCTAssertNoDiff(mapTitles(), [
            "Сумма перевода",
            // "Наименование ТСП",
            "Дата и время операции (МСК)",
            "Статус операции",
            // "Счет списания",
            // "Получатель",
            // "Банк получателя"
        ], "Merchant Icon cannot be produced due to SVG dance.")
    }
    
    func test_init_fromJSON_sberQR() throws {
        
        let data = try XCTUnwrap(String.sberQRWithOperationDetailData.data(using: .utf8))
        let response = try JSONDecoder().decode(SberQRResponse.self, from: data)
        
        try XCTAssertNoThrow(XCTUnwrap(response.data))
    }
    
    // MARKL: - Helpers
    
    private func mapTitles(
        operationStatus: OperationDetailData.OperationStatus = .complete
    ) throws -> [String] {
        
        let data: OperationDetailData = .stub(
            operationStatus: operationStatus
        )
        let models = data.sberQRPayment(formatAmount: { "\($1) \($0)" })
        
        return models.map(\.title)
    }
    
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
    "payerFullName": "Самвел Петрович",
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
