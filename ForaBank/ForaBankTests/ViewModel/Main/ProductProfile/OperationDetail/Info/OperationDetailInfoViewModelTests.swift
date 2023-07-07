//
//  OperationDetailInfoViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 30.06.2023.
//

@testable import ForaBank
import XCTest

final class OperationDetailInfoViewModelTests: XCTestCase {
    
    // MARK: init - external entity
    // OperationDetailInfoViewModel.swift:1490
    
    func test_init_shouldReturnPayeeAccountNumberAndPayeeBankBICOnMissingProduct() {
        
        let (sut, model) = makeSUT()
        
        XCTAssertNoDiff(sut.testCells, [
            .payeeAccountNumber,
            .payeeBankBIC,
        ])
        XCTAssertTrue(model.products.value.isEmpty)
    }
    
    func test_init_shouldReturnCellsWithoutPayeeInnOnNilPayeeINN() {
        
        let (detail, products) = makeStubs(
            productID: 12345,
            payeeINN: nil
        )
        let (sut, model) = makeSUT(
            detail: detail,
            products: products
        )
        
        XCTAssertNoDiff(sut.testCells, [
            .payee,
            .payeeAccountNumber,
            .payeeBankBIC,
            .purpose,
            .date,
        ])
        XCTAssertNoDiff(model.products.value.values.map { $0.map(\.id) }, [[12345]])
        XCTAssertNil(detail.payeeINN)
    }
    
    func test_init_shouldReturnCellsWithPayeeInn() {
        
        let (detail, products) = makeStubs(
            productID: 12345,
            payeeINN: "772016190450"
        )
        let (sut, model) = makeSUT(
            detail: detail,
            products: products
        )
        
        XCTAssertNoDiff(sut.testCells, [
            .payee,
            .payeeAccountNumber,
            .payeeINN,
            .payeeBankBIC,
            .purpose,
            .date,
        ])
        XCTAssertNoDiff(model.products.value.values.map { $0.map(\.id) }, [[12345]])
        XCTAssertNotNil(detail.payeeINN)
    }
    
    // MARK: - makeItemsForExternal entity
    
    func test_makeItemsForExternal_entity_shouldReturnEmpty_onNilTransferType() {
        
        let detail = makeExternal(externalTransferType: nil)
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [])
        XCTAssertNil(detail.payeeINN)
        XCTAssertEqual(detail.externalTransferType, .none)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnEmpty_onNil() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
        ])
        XCTAssertNil(detail.payeeINN)
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnPayeeName() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, .init(title: "payee Name", iconType: nil, value: "Mr Payee"), nil, nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .property(title: "payee Name", value: "Mr Payee"),
            .payeeAccountNumber,
            .payeeBankBIC,
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnProduct() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, .init(title: "payee", icon: .checkImage, name: "Payee", iconPaymentService: nil, balance: "1234", description: "Payee Description"), nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .product(title: "payee", name: "Payee", balance: "1234", description: "Payee Description"),
            .payeeBankBIC,
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnBank() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, nil, .init(title: "Bank", icon: .checkImage, name: "Bank Detail"), nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
            .bank(title: "Bank", name: "Bank Detail"),
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnAmount() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, .init(title: "Amount", iconType: nil, value: "1234"), nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
            .amount,
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnFee() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, .init(title: "Fee", iconType: nil, value: "345"), nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
            .fee
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnPayer() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, .init(title: "payer", icon: .checkImage, name: "Payer", iconPaymentService: nil, balance: "9876", description: "PayerDescription"), nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
            .payer,
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnPurpose() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, .init(title: "purpose", iconType: nil, value: "Payment Purpose"), nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "purpose", value: "Payment Purpose")
,
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnDate() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, nil, .init(title: "DATE", iconType: nil, value: "30.06.2023 12:32:41"))
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "DATE", value: "30.06.2023 12:32:41"),
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnCells() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeItemsForExternal(
            detail,
            .init(title: "payee Name", iconType: nil, value: "Mr Payee"),
            .init(title: "payee", icon: .checkImage, name: "Payee", iconPaymentService: nil, balance: "1234", description: "Payee Description"),
            .init(title: "Bank", icon: .checkImage, name: "Bank Detail"),
            .init(title: "Amount", iconType: nil, value: "1234"),
            .init(title: "Fee", iconType: nil, value: "345"),
            .init(title: "payer", icon: .checkImage, name: "Payer", iconPaymentService: nil, balance: "9876", description: "PayerDescription"),
            .init(title: "purpose", iconType: nil, value: "Payment Purpose"),
            .init(title: "DATE", iconType: nil, value: "30.06.2023 12:32:41")
        )
        
        XCTAssertNoDiff(cells, [
            .property(title: "payee Name", value: "Mr Payee"),
            .payeeAccountNumber,
            .product(title: "payee", name: "Payee", balance: "1234", description: "Payee Description"),
            .payeeBankBIC,
            .bank(title: "Bank", name: "Bank Detail"),
            .property(title: "Amount", value: "1234"),
            .property(title: "Fee", value: "345"),
            .product(title: "payer", name: "Payer", balance: "9876", description: "PayerDescription"),
            .property(title: "purpose", value: "Payment Purpose"),
            .property(title: "DATE", value: "30.06.2023 12:32:41"),
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnPayeeINN() {
        
        let detail = makeExternal(
            externalTransferType: .entity,
            payeeINN: "772016190450"
        )
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeINN,
            .payeeBankBIC,
        ])
        XCTAssertNotNil(detail.payeeINN)
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnPayeeKPP() {
        
        let detail = makeExternal(
            externalTransferType: .entity,
            payeeKPP: "770801001"
        )
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeKPP,
            .payeeBankBIC,
        ])
        XCTAssertNotNil(detail.payeeKPP)
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForExternal_entity_shouldReturnPayeeINNAndPayeeKPP() {
        
        let detail = makeExternal(
            externalTransferType: .entity,
            payeeINN: "772016190450",
            payeeKPP: "770801001"
        )
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeINN,
            .payeeKPP,
            .payeeBankBIC
        ])
        XCTAssertNotNil(detail.payeeINN)
        XCTAssertNotNil(detail.payeeKPP)
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    // MARK: - makeItemsForExternal individual
    
    func test_makeItemsForExternal_individual_shouldReturnCells() {
        
        let detail = makeExternal(externalTransferType: .individual)
        
        let cells = makeItemsForExternal(
            detail,
            .init(title: "payee Name", iconType: nil, value: "Mr Payee"),
            .init(title: "payee", icon: .checkImage, name: "Payee", iconPaymentService: nil, balance: "1234", description: "Payee Description"),
            .init(title: "Bank", icon: .checkImage, name: "Bank Detail"),
            .init(title: "Amount", iconType: nil, value: "1234"),
            .init(title: "Fee", iconType: nil, value: "345"),
            .init(title: "payer", icon: .checkImage, name: "Payer", iconPaymentService: nil, balance: "9876", description: "PayerDescription"),
            .init(title: "purpose", iconType: nil, value: "Payment Purpose"),
            .init(title: "DATE", iconType: nil, value: "30.06.2023 12:32:41")
        )
        
        XCTAssertNoDiff(cells, [
            .property(title: "payee Name", value: "Mr Payee"),
            .payeeAccountNumber,
            .product(title: "payee", name: "Payee", balance: "1234", description: "Payee Description"),
            .payeeBankBIC,
            .bank(title: "Bank", name: "Bank Detail"),
            .property(title: "Amount", value: "1234"),
            .property(title: "Fee", value: "345"),
            .product(title: "payer", name: "Payer", balance: "9876", description: "PayerDescription"),
            .property(title: "purpose", value: "Payment Purpose"),
            .property(title: "DATE", value: "30.06.2023 12:32:41"),
        ])
        XCTAssertEqual(detail.externalTransferType, .individual)
    }
    
    func test_makeItemsForExternal_individual_shouldNotReturnPayeeINNAndPayeeKPP() {
        
        let detail = makeExternal(
            externalTransferType: .individual,
            payeeINN: "772016190450",
            payeeKPP: "770801001"
        )
        
        let cells = makeItemsForExternal(detail, nil, nil, nil, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .payeeAccountNumber,
            .payeeBankBIC,
        ])
        XCTAssertNotNil(detail.payeeINN)
        XCTAssertNotNil(detail.payeeKPP)
        XCTAssertEqual(detail.externalTransferType, .individual)
    }
    
    // MARK: - Helpers
    
    private func makeItemsForExternal(
        dictionaryFullBankInfoBank: @escaping (String) -> BankFullInfoData? = { _ in nil },
        _ operation: OperationDetailData,
        _ payeeNameViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ payeeViewModel: OperationDetailInfoViewModel.ProductCellViewModel?,
        _ payeeBankViewModel: OperationDetailInfoViewModel.BankCellViewModel?,
        _ amountViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ commissionViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ payerViewModel: OperationDetailInfoViewModel.ProductCellViewModel?,
        _ purposeViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ dateViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?
    ) -> [OperationDetailInfoViewModel.TestCell] {
        
        OperationDetailInfoViewModel
            .makeItemsForExternal(dictionaryFullBankInfoBank: dictionaryFullBankInfoBank, operation, payeeNameViewModel, payeeViewModel, payeeBankViewModel, amountViewModel, commissionViewModel, payerViewModel, purposeViewModel, dateViewModel)
            .map(\.testCell)
    }
    
    private func makeStubs(
        externalTransferType: OperationDetailData.ExternalTransferType = .entity,
        productID: Int,
        payeeINN: String? = nil
    ) -> (
        detail: OperationDetailData,
        products: ProductsData
    ) {
        return (
            makeExternal(
                externalTransferType: externalTransferType,
                productID: productID,
                payeeINN: payeeINN
            ),
            [.card: [.stub(productId: productID)]]
        )
    }
    
    private func makeSUT(
        detail: OperationDetailData? = nil,
        externalTransferType: OperationDetailData.ExternalTransferType = .entity,
        products: ProductsData = [:],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: OperationDetailInfoViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        model.products.value = products
        
        let sut = OperationDetailInfoViewModel(
            model: model,
            operation: detail ?? makeExternal(externalTransferType: externalTransferType),
            dismissAction: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
     
    private func makeExternal(
        externalTransferType: OperationDetailData.ExternalTransferType?,
        productID: Int = 123,
        payeeAccountId: Int = 234,
        payeeINN: String? = nil,
        payeeKPP: String? = nil,
        payerAccountId: Int = 345
    ) -> OperationDetailData {
        
        .stub(
            amount: 1111.0,
            claimId: "6e9f2bcf-5cfe-408a-b908-8babc48cb658",
            comment: "Lorem ipsum dolor sit amet",
            currencyAmount: "RUB",
            dateForDetail: "30 июня 2023, 12:32",
            externalTransferType: externalTransferType,
            isForaBank: false,
            isTrafficPoliceService: false,
            operation: "Перевод юридическому лицу в сторонний банк",
            payeeAccountId: payeeAccountId,
            payeeAccountNumber: "40802810938050002771",
            payeeBankBIC: "044525225",
            payeeBankCorrAccount: "30101810400000000225",
            payeeBankName: "ПАО СБЕРБАНК",
            payeeCurrency: "RUB",
            payeeFullName: "ИП Домрачев Сергей Николаевич",
            payeeINN: payeeINN,
            payeeKPP: payeeKPP,
            payerAccountId: payerAccountId,
            payerAccountNumber: "40817810152005001180",
            payerAddress: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 117546, Москва г, Медынская ул ,  д. 4,  корп. 1,  кв. 12",
            payerAmount: 1141.0,
            payerCardId: productID,
            payerCardNumber: "**** **** **56 7803",
            payerCurrency: "RUB",
            payerFee: 30.0,
            payerFirstName: "Александра",
            payerFullName: "Меньшикова Александра Андреевна",
            payerINN: "290219523205",
            payerMiddleName: "Андреевна",
            paymentOperationDetailId: 65329,
            printFormType: .external,
            requestDate: "30.06.2023 12:32:41",
            responseDate: "30.06.2023 12:33:28",
            returned: false,
            transferDate: "30.06.2023",
            transferEnum: .external,
            cursivePayerAmount: "Одна тысяча сто сорок один рубль 00 копеек",
            cursiveAmount: "Одна тысяча сто одиннадцать рублей 00 копеек"
        )
    }
}

private extension OperationDetailInfoViewModel.DefaultCellViewModel {
    
    var testCell: OperationDetailInfoViewModel.TestCell { .init(self) }
}

private extension OperationDetailInfoViewModel {
    
    var testCells: [TestCell] { cells.map(\.testCell) }
    
    enum TestCell: Equatable {
        
        case `default`(title: String)
        case bank(title: String, name: String)
        case icon(title: String)
        case product(title: String, name: String, balance: String, description: String)
        case property(title: String, value: String)
    }
}

private extension OperationDetailInfoViewModel.TestCell {
    
    static let payee: Self = .property(title: "Получатель", value: "ИП Домрачев Сергей Николаевич")
    static let payeeAccountNumber: Self = .property(title: "Номер счета получателя", value: "40802810938050002771")
    static let payeeBankBIC: Self = .bank(title: "Бик банка получателя", name: "044525225")
    static let payeeINN: Self = .property(title: "ИНН получателя", value: "772016190450")
    static let payeeKPP: Self = .property(title: "КПП получателя", value: "770801001")
    static let purpose: Self = .property(title: "Назначение платежа", value: "Lorem ipsum dolor sit amet")
    static let amount: Self = .property(title: "Amount", value: "1234")
    static let fee: Self = .property(title: "Fee", value: "345")
    static let payer: Self = .product(title: "payer", name: "Payer", balance: "9876", description: "PayerDescription")
    static let date: Self = .property(title: "Дата и время операции (МСК)", value: "30.06.2023 12:33:28")
}

private extension OperationDetailInfoViewModel.TestCell {
    
    init(_ cell: OperationDetailInfoViewModel.DefaultCellViewModel) {
        
        switch cell {
        case let viewModel as OperationDetailInfoViewModel.BankCellViewModel:
            self = .bank(
                title: viewModel.title,
                name: viewModel.name
            )
            
        case let viewModel as OperationDetailInfoViewModel.IconCellViewModel:
            self = .icon(
                title: viewModel.title
            )
            
        case let viewModel as OperationDetailInfoViewModel.ProductCellViewModel:
            self = .product(
                title: viewModel.title,
                name: viewModel.name,
                balance: viewModel.balance,
                description: viewModel.description
            )
            
        case let viewModel as OperationDetailInfoViewModel.PropertyCellViewModel:
            self = .property(
                title: viewModel.title,
                value: viewModel.value
            )
            
        default:
            self = .default(
                title: cell.title
            )
        }
    }
}

private extension OperationDetailData {
    
    static func stub(
        oktmo: String? = nil,
        account: String? = nil,
        accountTitle: String? = nil,
        amount: Double,
        billDate: String? = nil,
        billNumber: String? = nil,
        claimId: String,
        comment: String? = nil,
        countryName: String? = nil,
        currencyAmount: String,
        dateForDetail: String,
        division: String? = nil,
        driverLicense: String? = nil,
        externalTransferType: OperationDetailData.ExternalTransferType? = nil,
        isForaBank: Bool? = nil,
        isTrafficPoliceService: Bool = false,
        memberId: String? = nil,
        operation: String? = nil,
        payeeAccountId: Int? = nil,
        payeeAccountNumber: String? = nil,
        payeeAmount: Double? = nil,
        payeeBankBIC: String? = nil,
        payeeBankCorrAccount: String? = nil,
        payeeBankName: String? = nil,
        payeeCardId: Int? = nil,
        payeeCardNumber: String? = nil,
        payeeCurrency: String? = nil,
        payeeFirstName: String? = nil,
        payeeFullName: String? = nil,
        payeeINN: String? = nil,
        payeeKPP: String? = nil,
        payeeMiddleName: String? = nil,
        payeePhone: String? = nil,
        payeeSurName: String? = nil,
        payerAccountId: Int,
        payerAccountNumber: String,
        payerAddress: String,
        payerAmount: Double,
        payerCardId: Int? = nil,
        payerCardNumber: String? = nil,
        payerCurrency: String,
        payerDocument: String? = nil,
        payerFee: Double,
        payerFirstName: String,
        payerFullName: String,
        payerINN: String? = nil,
        payerMiddleName: String? = nil,
        payerPhone: String? = nil,
        payerSurName: String? = nil,
        paymentOperationDetailId: Int,
        paymentTemplateId: Int? = nil,
        period: String? = nil,
        printFormType: PrintFormType,
        provider: String? = nil,
        puref: String? = nil,
        regCert: String? = nil,
        requestDate: String,
        responseDate: String,
        returned: Bool? = nil,
        transferDate: String,
        transferEnum: OperationDetailData.TransferEnum? = nil,
        transferNumber: String? = nil,
        transferReference: String? = nil,
        cursivePayerAmount: String? = nil,
        cursivePayeeAmount: String? = nil,
        cursiveAmount: String? = nil,
        serviceSelect: String? = nil,
        serviceName: String? = nil,
        merchantSubName: String? = nil,
        merchantIcon: String? = nil,
        operationStatus: OperationDetailData.OperationStatus? = nil,
        shopLink: String? = nil,
        payeeCheckAccount: String? = nil,
        depositNumber: String? = nil,
        depositDateOpen: String? = nil,
        currencyRate: Double? = nil,
        mcc: String? = nil,
        printData: OperationDetailData.PrintMapData? = nil,
        paymentMethod: OperationDetailData.PaymentMethod? = nil
    ) -> Self {
        
        .init(
            oktmo: account,
            account: account,
            accountTitle: accountTitle,
            amount: amount,
            billDate: billDate,
            billNumber: billNumber,
            claimId: claimId,
            comment: comment,
            countryName: countryName,
            currencyAmount: currencyAmount,
            dateForDetail: dateForDetail,
            division: division,
            driverLicense: driverLicense,
            externalTransferType: externalTransferType,
            isForaBank: isForaBank,
            isTrafficPoliceService: isTrafficPoliceService,
            memberId: memberId,
            operation: operation,
            payeeAccountId: payeeAccountId,
            payeeAccountNumber: payeeAccountNumber,
            payeeAmount: payeeAmount,
            payeeBankBIC: payeeBankBIC,
            payeeBankCorrAccount: payeeBankCorrAccount,
            payeeBankName: payeeBankName,
            payeeCardId: payeeCardId,
            payeeCardNumber: payeeCardNumber,
            payeeCurrency: payeeCurrency,
            payeeFirstName: payeeFirstName,
            payeeFullName: payeeFullName,
            payeeINN: payeeINN,
            payeeKPP: payeeKPP,
            payeeMiddleName: payeeMiddleName,
            payeePhone: payeePhone,
            payeeSurName: payeeSurName,
            payerAccountId: payerAccountId,
            payerAccountNumber: payerAccountNumber,
            payerAddress: payerAddress,
            payerAmount: payerAmount,
            payerCardId: payerCardId,
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
            paymentOperationDetailId: paymentOperationDetailId,
            paymentTemplateId: paymentTemplateId,
            period: period,
            printFormType: printFormType,
            provider: provider,
            puref: puref,
            regCert: regCert,
            requestDate: requestDate,
            responseDate: responseDate,
            returned: returned,
            transferDate: transferDate,
            transferEnum: transferEnum,
            transferNumber: transferNumber,
            transferReference: transferReference,
            cursivePayerAmount: cursivePayerAmount,
            cursivePayeeAmount: cursivePayeeAmount,
            cursiveAmount: cursiveAmount,
            serviceSelect: serviceSelect,
            serviceName: serviceName,
            merchantSubName: merchantSubName,
            merchantIcon: merchantIcon,
            operationStatus: operationStatus,
            shopLink: shopLink,
            payeeCheckAccount: payeeCheckAccount,
            depositNumber: depositNumber,
            depositDateOpen: depositDateOpen,
            currencyRate: currencyRate,
            mcc: mcc,
            printData: printData,
            paymentMethod: paymentMethod
        )
    }
}
