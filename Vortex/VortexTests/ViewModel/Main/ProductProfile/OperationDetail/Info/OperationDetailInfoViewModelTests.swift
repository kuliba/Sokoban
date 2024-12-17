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
    
    // MARK: - makeItemsForTransport
    
    func test_makeItemsForTransport_shouldReturnEmpty_onNilTransferType() {
        
        let detail = makeOperationDetail(transferEnum: nil)
        
        let cells = makeItemsForTransport(detail, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [])
        XCTAssertEqual(detail.transferEnum, .none)
    }
    
    func test_makeItemsForTransport_transport_shouldReturnEmpty_onNil() {
        
        let detail = makeOperationDetail(transferEnum: .transport)
        
        let cells = makeItemsForTransport(detail, nil, nil, nil, nil, nil)

        XCTAssertNoDiff(cells, [])
        XCTAssertEqual(detail.transferEnum, .transport)
    }
    
    func test_makeItemsForTransport_shouldReturnAmount() {
        
        let detail = makeOperationDetail(transferEnum: .transport)
        
        let cells = makeItemsForTransport(detail, .init(title: "Сумма", iconType: nil, value: "100"), nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .property(title: "Сумма", value: "100")
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }
    
    func test_makeItemsForTransport_shouldReturnCommission() {
        
        let detail = makeOperationDetail(transferEnum: .transport)
        
        let cells = makeItemsForTransport(detail, nil, .init(title: "Commission", iconType: nil, value: "0.01"), nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .property(title: "Commission", value: "0.01")
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }

    func test_makeItemsForTransport_shouldReturnPayer() {
        
        let detail = makeOperationDetail(transferEnum: .transport)
        
        let cells = makeItemsForTransport(detail, nil, nil, .init(title: "Payer", icon: .checkImage, name: "Ivanov", iconPaymentService: nil, balance: "100", description: "Payer description"), nil, nil)
        
        XCTAssertNoDiff(cells, [
            .product(title: "Payer", name: "Ivanov", balance: "100", description: "Payer description"),
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }

    func test_makeItemsForTransport_shouldReturnPayee() {
        
        let detail = makeOperationDetail(transferEnum: .transport)
        
        let cells = makeItemsForTransport(detail, nil, nil, nil, .init(title: "Payee", icon: .checkImage, name: "Ivanov", iconPaymentService: nil, balance: "100", description: "Payee description"), nil)
        
        XCTAssertNoDiff(cells, [
            .product(title: "Payee", name: "Ivanov", balance: "100", description: "Payee description"),
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }

    func test_makeItemsForTransport_shouldReturnDate() {
        
        let detail = makeOperationDetail(transferEnum: .transport)
        
        let cells = makeItemsForTransport(detail, nil, nil, nil, nil, .init(title: "Date", iconType: nil, value: "10:30"))
        
        XCTAssertNoDiff(cells, [
            .property(title: "Date", value: "10:30")
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }
    
    func test_makeItemsForTransport_isTrafficPoliceServiceIsFalse_shouldAccountTitle() {
        
        let detail = makeOperationDetail(
            transferEnum: .transport,
            account: "1111",
            accountTitle: "Номер карты"
        )
        
        let cells = makeItemsForTransport(detail, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .property(title: "Номер карты", value: "1111")
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }

    func test_makeItemsForTransport_isTrafficPoliceServiceIsTrue_shouldAccountTitle() {
        
        let detail = makeOperationDetail(
            isTrafficPoliceService: true,
            transferEnum: .transport,
            account: "1111",
            accountTitle: "Номер карты"
        )
        
        let cells = makeItemsForTransport(detail, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .property(title: "Номер карты", value: "1111")
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }
    
    func test_makeItemsForTransport_accountIsEmpty_shouldReturnEmptyAccountTitle() {
        
        let detail = makeOperationDetail(
            isTrafficPoliceService: true,
            transferEnum: .transport,
            account: "",
            accountTitle: "Номер карты"
        )
        
        let cells = makeItemsForTransport(detail, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [])
        XCTAssertEqual(detail.transferEnum, .transport)
    }

    func test_makeItemsForTransport_shouldName() {
        
        let detail = makeOperationDetail(transferEnum: .transport, payeeFullName: "Паркинг")
        
        let cells = makeItemsForTransport(dictionaryAnywayOperator: {_ in .iForaMosParking}, detail, nil, nil, nil, nil, nil)
        
        XCTAssertNoDiff(cells, [
            .property(title: "Наименование получателя", value: "Паркинг")
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }

    func test_makeItemsForTransport_shouldReturnCells() {
        
        let detail = makeOperationDetail(transferEnum: .transport, payeeFullName: "Паркинг")
        
        let cells = makeItemsForTransport(
            detail,
            .init(title: "Сумма", iconType: nil, value: "100"),
            .init(title: "Commission", iconType: nil, value: "0.01"),
            .init(title: "Payer", icon: .checkImage, name: "Ivanov", iconPaymentService: nil, balance: "100", description: "Payer description"),
            .init(title: "Payee", icon: .checkImage, name: "Ivanov", iconPaymentService: nil, balance: "101", description: "Payee description"),
            .init(title: "Date", iconType: nil, value: "10:30"))
        
        XCTAssertNoDiff(cells, [
            .property(title: "Наименование получателя", value: "Паркинг"),
            .property(title: "Сумма", value: "100"),
            .property(title: "Commission", value: "0.01"),
            .product(title: "Payer", name: "Ivanov", balance: "100", description: "Payer description"),
            .product(title: "Payee", name: "Ivanov", balance: "101", description: "Payee description"),
            .property(title: "Date", value: "10:30")
        ])
        XCTAssertEqual(detail.transferEnum, .transport)
    }
    
    // MARK: - makeItemsForHistoryExternal
        
    func test_makeItemsForHistoryExternal_entity_shouldReturnEmpty_onNil() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeHistoryItemsForExternal(.entity, detail, nil, nil, nil, "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForHistoryExternal_individual_shouldReturnEmpty_onNil() {
        
        let detail = makeExternal(externalTransferType: .individual)
        
        let cells = makeHistoryItemsForExternal(.individual, detail, nil, nil, nil, "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .individual)
    }
    
    func test_makeItemsForHistoryExternal_entity_shouldReturnAmount() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeHistoryItemsForExternal(.entity, detail, .init(title: "Сумма", iconType: nil, value: "100"), nil, nil, "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Сумма", value: "100"),
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForHistoryExternal_individual_shouldReturnAmount() {
        
        let detail = makeExternal(externalTransferType: .individual)
        
        let cells = makeHistoryItemsForExternal(.individual, detail, .init(title: "Сумма", iconType: nil, value: "100"), nil, nil, "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Сумма", value: "100"),
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .individual)
    }

    func test_makeItemsForHistoryExternal_entity_shouldReturnCommission() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeHistoryItemsForExternal(.entity, detail, nil, .init(title: "Commission", iconType: nil, value: "1"), nil, "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Commission", value: "1"),
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForHistoryExternal_individual_shouldReturnCommission() {
        
        let detail = makeExternal(externalTransferType: .individual)
        
        let cells = makeHistoryItemsForExternal(.individual, detail, nil, .init(title: "Commission", iconType: nil, value: "1"), nil, "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Commission", value: "1"),
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .individual)
    }

    func test_makeItemsForHistoryExternal_entity_shouldReturnDebitAccount() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeHistoryItemsForExternal(.entity, detail, nil, nil, .init(title: "DebitAccount"), "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .default(title: "DebitAccount"),
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForHistoryExternal_individual_shouldReturnDebitAccount() {
        
        let detail = makeExternal(externalTransferType: .individual)
        
        let cells = makeHistoryItemsForExternal(.individual, detail, nil, nil, .init(title: "DebitAccount"), "", "")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .default(title: "DebitAccount"),
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .individual)
    }
    
    func test_makeItemsForHistoryExternal_entity_shouldReturnCommentAndDate() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeHistoryItemsForExternal(.entity, detail, nil, nil, nil, "Comment", "10:10")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Назначение платежа", value: "Comment"),
            .property(title: "Дата и время операции (МСК)", value: "10:10")
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }
    
    func test_makeItemsForHistoryExternal_individual_shouldReturnCommentAndDate() {
        
        let detail = makeExternal(externalTransferType: .individual)
        
        let cells = makeHistoryItemsForExternal(.individual, detail, nil, nil, nil, "Comment", "10:10")

        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Назначение платежа", value: "Comment"),
            .property(title: "Дата и время операции (МСК)", value: "10:10")
        ])
        XCTAssertEqual(detail.externalTransferType, .individual)
    }

    func test_makeItemsForHistoryExternal_entity_shouldReturnCells() {
        
        let detail = makeExternal(externalTransferType: .entity)
        
        let cells = makeHistoryItemsForExternal(
            .entity,
            detail,
            .init(title: "Amount", iconType: nil, value: "1234"),
            .init(title: "Fee", iconType: nil, value: "345"),
            .init(title: "DebitAccount"),
            "Comment",
            "10:10"
        )
        
        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Amount", value: "1234"),
            .property(title: "Fee", value: "345"),
            .default(title: "DebitAccount"),
            .property(title: "Назначение платежа", value: "Comment"),
            .property(title: "Дата и время операции (МСК)", value: "10:10")
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }

    func test_makeItemsForHistoryExternal_individual_shouldReturnCells() {
        
        let detail = makeExternal(externalTransferType: .individual)
        
        let cells = makeHistoryItemsForExternal(
            .individual,
            detail,
            .init(title: "Amount", iconType: nil, value: "1234"),
            .init(title: "Fee", iconType: nil, value: "345"),
            .init(title: "DebitAccount"),
            "Comment",
            "10:10"
        )
        
        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeBankBIC,
            .property(title: "Amount", value: "1234"),
            .property(title: "Fee", value: "345"),
            .default(title: "DebitAccount"),
            .property(title: "Назначение платежа", value: "Comment"),
            .property(title: "Дата и время операции (МСК)", value: "10:10")
        ])
        XCTAssertEqual(detail.externalTransferType, .individual)
    }

    func test_makeItemsForHistoryExternal_entity_shouldReturnPayeeKPP() {
        
        let detail = makeExternal(
            externalTransferType: .entity,
            payeeINN: "772016190450",
            payeeKPP: "770801001"
        )
        
        let cells = makeHistoryItemsForExternal(.entity, detail, nil, nil, nil, "", "")
        
        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeINN,
            .payeeKPP,
            .payeeBankBIC,
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertNotNil(detail.payeeINN)
        XCTAssertNotNil(detail.payeeKPP)
        XCTAssertEqual(detail.externalTransferType, .entity)
    }

    func test_makeItemsForHistoryExternal_individual_shouldNotReturnPayeeKPP() {
        
        let detail = makeExternal(
            externalTransferType: .individual,
            payeeINN: "772016190450",
            payeeKPP: "770801001"
        )
        
        let cells = makeHistoryItemsForExternal(.individual, detail, nil, nil, nil, "", "")
        
        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeAccountNumber,
            .payeeINN,
            .payeeBankBIC,
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertNotNil(detail.payeeINN)
        XCTAssertNotNil(detail.payeeKPP)
        XCTAssertEqual(detail.externalTransferType, .individual)
    }
    
    func test_makeItemsForHistoryExternal_entity_shouldReturnCardNumberIfAccountNumberEmpty() {
        
        let detail = makeExternal(
            externalTransferType: .entity,
            payeeAccountNumber: nil
        )
        
        let cells = makeHistoryItemsForExternal(.entity, detail, nil, nil, nil, "", "")
        
        XCTAssertNoDiff(cells, [
            .payeeName,
            .payeeCardNumber,
            .payeeBankBIC,
            .commentEmpty,
            .dateEmpty
        ])
        XCTAssertEqual(detail.externalTransferType, .entity)
    }

    // MARK: - test logo
    
    func test_logo_sfp() {
        
        let detail = makeOperationDetail(transferEnum: .sfp)
        
        let (_, model) = makeSUT(transferEnum: .sfp)
        
        let logo = OperationDetailInfoViewModel.logo(model: model, operation: detail)
        
        XCTAssertNoDiff(logo, .ic24Sbp)
    }
    
    func test_logo_internet() {
        
        let detail = makeOperationDetail(transferEnum: .internet)
        
        let (_, model) = makeSUT(transferEnum: .internet)
        
        let logo = OperationDetailInfoViewModel.logo(model: model, operation: detail)
        
        XCTAssertNoDiff(logo, .ic40TvInternet)
    }
    
    func test_logo_housingAndCommunalService() {
        
        let detail = makeOperationDetail(transferEnum: .housingAndCommunalService)
        
        let (_, model) = makeSUT(transferEnum: .housingAndCommunalService)
        
        let logo = OperationDetailInfoViewModel.logo(model: model, operation: detail)
        
        XCTAssertNoDiff(logo, .ic40ZkxServices)
    }
    
    func test_logo_transport() {
        
        let detail = makeOperationDetail(transferEnum: .transport)
        
        let (_, model) = makeSUT(transferEnum: .transport)
        
        let logo = OperationDetailInfoViewModel.logo(model: model, operation: detail)
        
        XCTAssertNoDiff(logo, .ic40Transport)
    }
    
    func test_logo_otherTransfer_shouldReturnLogoNil() {
        
        let detail = makeOperationDetail(transferEnum: .depositClose)
        
        let (_, model) = makeSUT(transferEnum: .depositClose)
        
        let logo = OperationDetailInfoViewModel.logo(model: model, operation: detail)
        
        XCTAssertNil(logo)
    }
    
    // MARK: - test makePropertyViewModel
        
    func test_makePropertyViewModel_balance_shouldReturnAmount() {
        
        let (detail, products) = makeStubs(transferEnum: .internet)
        
        let (sut, model) =  makeSUT(
            transferEnum: .internet,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .balance)
        
        XCTAssertNoDiff(cell?.title, "Сумма перевода")
        XCTAssertNoDiff(cell?.value, model.amount)
    }
    
    func test_makePropertyViewModel_commission_shouldReturnCommission() {
        
        let currency: CurrencyData = .rub
        let (detail, products) = makeStubs(
            transferEnum: .transport,
            currency: currency.code
        )
        
        let (sut, model) =  makeSUT(
            transferEnum: .transport,
            detail: detail,
            products: products,
            currencyList: [currency]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .commission)

        XCTAssertNoDiff(cell?.title, "Комиссия")
        XCTAssertNoDiff(cell?.value, model.commission)
    }
    
    func test_makePropertyViewModel_purpose_commentNil_shouldReturnNil() {
        
        let detail = makeOperationDetail(
            comment: nil
        )
        
        let (sut, _) =  makeSUT(
            transferEnum: .transport,
            detail: detail
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .purpose)
        
        XCTAssertNil(cell)
    }

    func test_makePropertyViewModel_purpose_commentEmpty_shouldReturnNil() {
        
        let (detail, products) = makeStubs(
            comment: ""
        )
        
        let (sut, _) =  makeSUT(
            transferEnum: .transport,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .purpose)
        
        XCTAssertNil(cell)
    }
    
    func test_makePropertyViewModel_date_notDepositClose_shouldReturnDate() {
        
        let (detail, products) = makeStubs()
        
        let (sut, _) =  makeSUT(
            transferEnum: .transport,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .date)
        
        XCTAssertNoDiff(cell?.title, "Дата и время операции (МСК)")
        XCTAssertNoDiff(cell?.value, "30.06.2023 12:33:28")
    }
    
    func test_makePropertyViewModel_date_depositClose_shouldReturnType() {
        
        let (detail, products) = makeStubs(
            transferEnum: .depositClose
        )
        
        let (sut, _) =  makeSUT(
            transferEnum: .depositClose,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .date)
        
        XCTAssertNoDiff(cell?.title, "Тип платежа")
        XCTAssertNoDiff(cell?.value, "Закрытие вклада")
    }
    
    func test_makePropertyViewModel_phone_notSfp_shouldReturnPhone() {
        
        let (detail, products) = makeStubs(
            payeePhone: "+79998887766"
        )
        
        let (sut, _) =  makeSUT(
            transferEnum: .transport,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .phone)
        
        XCTAssertNoDiff(cell?.title, "Номер телефона получателя")
        XCTAssertNoDiff(cell?.value, "+7 999 888-77-66")
    }
    
    func test_makePropertyViewModel_phone_sfp_shouldReturnPhone() {
        
        let (detail, products) = makeStubs(
            transferEnum: .sfp,
            payeePhone: "9998887766"
        )
        
        let (sut, _) =  makeSUT(
            transferEnum: .sfp,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .phone)
        
        XCTAssertNoDiff(cell?.title, "Номер телефона получателя")
        XCTAssertNoDiff(cell?.value, "+7 999 888-77-66")
    }
    
    func test_makePropertyViewModel_operationNumber_transferNumberNil_shouldReturnNil() {
        
        let (detail, products) = makeStubs()
        
        let (sut, _) =  makeSUT(
            transferEnum: .transport,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .operationNumber)
        
        XCTAssertNil(cell)
    }

    func test_makePropertyViewModel_operationNumber_transferNumberNotNil_shouldReturNumber() {
        
        let (detail, products) = makeStubs(transferNumber: "111")
        
        let (sut, _) =  makeSUT(
            transferEnum: .transport,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .operationNumber)
        
        XCTAssertNoDiff(cell?.title, "Номер операции СБП")
        XCTAssertNoDiff(cell?.value, "111")
    }
    
    func test_makePropertyViewModel_default_shouldReturNil() {
        
        let (detail, products) = makeStubs(transferNumber: "111")
        
        let (sut, _) =  makeSUT(
            transferEnum: .transport,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        let cell = sut.makePropertyViewModel(productId: 123, operation: detail, iconType: .file)
        
        XCTAssertNil(cell)
    }

    // MARK: - C2BOperation Tests
    
    func test_c2BOperationDetails_makeItems_shouldReturnCellsC2B() {
        
        let (detail, products) = makeStubs(
            transferEnum: .c2bPayment,
            transferNumber: "transferNumber",
            productID: 1,
            currency: "RUB",
            productBalance: 10,
            payeeAccountId: 1,
            payeeBankName: "ПАО СБЕРБАНК",
            memberId: "1"
        )
        
        let (sut, _) =  makeSUT(
            transferEnum: .c2bPayment,
            detail: detail,
            products: products,
            currencyList: [.rub]
        )
        
        sut.cells = sut.makeItems(operation: detail)
        
        XCTAssertNoDiff(sut.testTitles, [
            "Сумма перевода",
            "Наименование ТСП",
            "Дата и время операции (МСК)",
            "Статус операции",
            "Счет списания",
            "Счет зачисления",
            "Банк получателя",
            "Назначение платежа",
            "Номер операции СБП"
        ])
    }
    
    func test_nameCompanyC2B_withMerchantSubName_shouldReturnCell() {
        
        let (sut, _) =  makeSUT()
        let (detail, _) = makeStubs(
            merchantSubName: "Company Name"
        )
        
        let companyCell = sut.nameCompanyC2B(operation: detail)
        
        XCTAssertNotNil(companyCell)
    }
    
    func test_nameCompanyC2B_withOutMerchantSubName_shouldReturnNil() {
        
        let (sut, _) =  makeSUT()
        let (detail, _) = makeStubs(
            merchantSubName: nil
        )
        
        let companyCell = sut.nameCompanyC2B(operation: detail)
        
        XCTAssertNil(companyCell)
    }
    
    func test_operationDetailStatus_shouldReturnCompleteCell() {
        
        let (detail, _) = makeStubs(
            operationStatus: .complete
        )
        
        let (sut, _) =  makeSUT()
        
        let cell = sut.operationDetailStatus(status: detail.operationStatus)
        XCTAssertEqual(cell?.name, "Успешно")
        XCTAssertEqual(cell?.title, "Статус операции")
    }
    
    func test_operationDetailStatus_shouldReturnInProgressCell() {
        
        let (detail, _) = makeStubs(
            operationStatus: .inProgress
        )
        
        let (sut, _) =  makeSUT()
        
        let cell = sut.operationDetailStatus(status: detail.operationStatus)
        XCTAssertEqual(cell?.name, "В обработке")
        XCTAssertEqual(cell?.title, "Статус операции")
    }
    
    func test_operationDetailStatus_shouldReturnRejectCell() {
        
        let (detail, _) = makeStubs(
            operationStatus: .rejected
        )
        
        let (sut, _) =  makeSUT()
        
        let cell = sut.operationDetailStatus(status: detail.operationStatus)
        XCTAssertEqual(cell?.name, "Отказ")
        XCTAssertEqual(cell?.title, "Статус операции")
    }
    
    // MARK: - SFP init case

    func test_init_withCreditOperation_initializesSuccessfully() throws {
        
        let (vm, _) = try makeSUTWithStatement()
        XCTAssertNotNil(vm)
    }
    
    func test_init_withDebitOperation_initializesSuccessfully() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(operationType: .debit))
        XCTAssertNotNil(vm)
    }
    
    func test_init_withCreditOperation_setsCellsCorrectlyWithPhoneNumber() throws {
        
        let (vm, _) = try makeSUTWithStatement()
        XCTAssertEqual(vm.cells.first?.title, "Номер телефона отправителя")
    }
    
    func test_init_withDebitOperation_setsCellsCorrectlyWithPhoneNumber() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(operationType: .debit))
        XCTAssertEqual(vm.cells.first?.title, "Номер телефона получателя")
    }
    
    func test_init_withCreditOperation_setsCellsCorrectlyWithoutPhoneNumber() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(fastPayment: nil))
        XCTAssertEqual(vm.cells.first?.title, "Отправитель")
    }
    
    func test_init_withDebitOperation_setsCellsCorrectlyWithoutPhoneNumber() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(fastPayment: nil, operationType: .debit))
        XCTAssertEqual(vm.cells.first?.title, "Получатель")
    }
    
    func test_init_withCreditOperationAndNoFastPayment_setsCellsCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(fastPayment: nil))
        
        XCTAssertEqual(vm.cells.count, 3)
        XCTAssertEqual(vm.cells[0].title, "Отправитель")
        XCTAssertEqual(vm.cells[1].title, "Сумма перевода")
        XCTAssertEqual(vm.cells[2].title, "Дата и время операции (МСК)")
    }
    
    func test_init_withDebitOperationAndNoFastPayment_setsCellsCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(fastPayment: nil, operationType: .debit))
        
        XCTAssertEqual(vm.cells.count, 3)
        XCTAssertEqual(vm.cells[0].title, "Получатель")
        XCTAssertEqual(vm.cells[1].title, "Сумма перевода")
        XCTAssertEqual(vm.cells[2].title, "Дата и время операции (МСК)")
    }
    func test_init_withCreditOperation_setsCellTitlesCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement()
        
        XCTAssertEqual(vm.cells.count, 7)
        XCTAssertEqual(vm.cells[0].title, "Номер телефона отправителя")
        XCTAssertEqual(vm.cells[1].title, "Отправитель")
        XCTAssertEqual(vm.cells[2].title, "Банк отправителя")
        XCTAssertEqual(vm.cells[3].title, "Сумма перевода")
        XCTAssertEqual(vm.cells[4].title, "Назначение платежа")
        XCTAssertEqual(vm.cells[5].title, "Номер операции СБП")
        XCTAssertEqual(vm.cells[6].title, "Дата и время операции (МСК)")
    }
    func test_init_withCreditFictOperation_setsCellsCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(operationType: .creditFict))
        XCTAssertEqual(vm.cells[0].title, "Номер телефона отправителя")
    }
    func test_init_withCreditPlanOperation_setsCellsCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(operationType: .creditPlan))
        XCTAssertEqual(vm.cells[0].title, "Номер телефона отправителя")
    }
    
    func test_init_withDebitOperation_setsCellTitlesCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(operationType: .debit))
        
        XCTAssertEqual(vm.cells[0].title, "Номер телефона получателя")
        XCTAssertEqual(vm.cells[1].title, "Получатель")
        XCTAssertEqual(vm.cells[2].title, "Банк получателя")
        XCTAssertEqual(vm.cells[3].title, "Сумма перевода")
        XCTAssertEqual(vm.cells[4].title, "Назначение платежа")
        XCTAssertEqual(vm.cells[5].title, "Номер операции СБП")
        XCTAssertEqual(vm.cells[6].title, "Дата и время операции (МСК)")
    }
    
    func test_init_withDebitFictOperation_setsCellsCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(operationType: .debitFict))
        XCTAssertEqual(vm.cells[0].title, "Номер телефона получателя")
    }
    
    func test_init_withDebitPlanOperation_setsCellsCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(operationType: .debitPlan))
        XCTAssertEqual(vm.cells[0].title, "Номер телефона получателя")
    }
    
    // MARK: - C2B init case
    
    func test_init_withC2bOperation_operationTypeCreditsetsCellsCorrectly() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(paymentDetailType: .c2b, operationType: .credit))
        
        XCTAssertEqual(vm.cells.count, 7)
        XCTAssertEqual(vm.cells[0].title, "Сумма перевода")
        XCTAssertEqual(vm.cells[1].title, "Дата и время операции (МСК)")
        XCTAssertEqual(vm.cells[2].title, "Отправитель")
        XCTAssertEqual(vm.cells[3].title, "Банк отправителя")
        XCTAssertEqual(vm.cells[4].title, "Сообщение получателю")
        XCTAssertEqual(vm.cells[5].title, "Идентификатор операции")
    }

    func test_init_withC2bOperation_setsCellsCorrectlyWithStatusComplete() throws {

        let operation = makeOperationDetail(operationStatus: .complete)
        let (vm, _) = try makeSUTWithStatement(detail: operation, statement: .makeStatementData(paymentDetailType: .c2b))
        if let cell = vm.cells[2] as? OperationDetailInfoViewModel.BankCellViewModel {
            XCTAssertEqual(cell.title, "Статус операции")
            XCTAssertEqual(cell.name, "Успешно")
        }
    }
    
    func test_init_withC2bOperation_setsCellsCorrectlyWithStatusInProgress() throws {
        
        let operation = makeOperationDetail(operationStatus: .inProgress)
        let (vm, _) = try makeSUTWithStatement(detail: operation, statement: .makeStatementData(paymentDetailType: .c2b))
        if let cell = vm.cells[2] as? OperationDetailInfoViewModel.BankCellViewModel {
            XCTAssertEqual(cell.title, "Статус операции")
            XCTAssertEqual(cell.name, "В обработке")
        }
    }
    
    func test_init_withC2bOperation_setsCellsCorrectlyWithStatusRejected() throws {
        
        let operation = makeOperationDetail(operationStatus: .rejected)
        let (vm, _) = try makeSUTWithStatement(detail: operation, statement: .makeStatementData(paymentDetailType: .c2b))
        if let cell = vm.cells[2] as? OperationDetailInfoViewModel.BankCellViewModel {
            XCTAssertEqual(cell.title, "Статус операции")
            XCTAssertEqual(cell.name, "Отказ")
        }
    }

    func test_init_withC2bOperation_setsCellsCorrectlyWithCancellation() throws {
        
        let (vm, _) = try makeSUTWithStatement(statement: .makeStatementData(paymentDetailType: .c2b, isCancellation: true))
        if let cell = vm.cells[2] as? OperationDetailInfoViewModel.BankCellViewModel {
            XCTAssertEqual(cell.title, "Детали операции")
            XCTAssertEqual(cell.name, "Отказ")
        }
       
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
    
    private func makeStubs(
        externalTransferType: OperationDetailData.ExternalTransferType? = nil,
        isTrafficPoliceService: Bool = false,
        transferEnum: OperationDetailData.TransferEnum? = nil,
        transferNumber: String? = nil,
        account: String? = nil,
        accountTitle: String? = nil,
        payeeFullName: String? = nil,
        payeePhone: String? = nil,
        productID: Int = 123,
        currency: String = "Rub",
        comment: String? = "Lorem ipsum dolor sit amet",
        operationStatus: OperationDetailData.OperationStatus = .complete,
        merchantSubName: String? = "merchantSubName",
        productBalance: Double? = nil,
        payeeAccountId: Int = 111,
        payeeBankName: String? = "ПАО СБЕРБАНК",
        memberId: String? = nil
    ) -> (
        detail: OperationDetailData,
        products: ProductsData
    ) {
        return (
            makeOperationDetail(
                externalTransferType: externalTransferType,
                isTrafficPoliceService: isTrafficPoliceService,
                transferEnum: transferEnum,
                transferNumber: transferNumber,
                account: account,
                accountTitle: accountTitle,
                payeeFullName: payeeFullName,
                payeePhone: payeePhone,
                productID: productID,
                comment: comment,
                operationStatus: operationStatus,
                merchantSubName: merchantSubName,
                payeeAccountId: payeeAccountId,
                payeeBankName: payeeBankName,
                memberId: memberId
            ),
            [.card: [
                .stub(
                    productId: productID,
                    currency: currency,
                    balance: productBalance
                )
            ]]
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
   
    private func makeSUTWithStatement(
        detail: OperationDetailData? = nil,
        statement: ProductStatementData = .makeStatementData(),
        externalTransferType: OperationDetailData.ExternalTransferType = .entity,
        products: ProductsData = [:],
        file: StaticString = #file,
        line: UInt = #line
    )  throws -> (
        sut: OperationDetailInfoViewModel,
        model: Model
    ) {
       
        let model: Model = .mockWithEmptyExcept()
        model.products.value = products
        model.currencyList.value.append(.rub)
        model.bankListFullInfo.value.append(.bank)
        
        let statement = ProductStatementData.makeStatementData(
            fastPayment: statement.fastPayment,
            paymentDetailType: statement.paymentDetailType,
            operationType: statement.operationType,
            currencyCodeNumeric: statement.currencyCodeNumeric,
            isCancellation: statement.isCancellation
        )
       
        let sut = try XCTUnwrap(OperationDetailInfoViewModel(
                with: statement,
                operation: detail,
                product: .loanStub1,
                dismissAction: {},
                model: model
            ))
       
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
        payerAccountId: Int = 345,
        payeeAccountNumber: String? = "40802810938050002771"
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
            payeeAccountNumber: payeeAccountNumber,
            payeeBankBIC: "044525225",
            payeeBankCorrAccount: "30101810400000000225",
            payeeBankName: "ПАО СБЕРБАНК",
            payeeCardNumber: "44444",
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
    
    private func makeItemsForTransport(
        dictionaryAnywayOperator: @escaping (String) -> OperatorGroupData.OperatorData? = { _ in nil },
        _ operation: OperationDetailData,
        _ amountViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ commissionViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ payerViewModel: OperationDetailInfoViewModel.ProductCellViewModel?,
        _ payeeViewModel: OperationDetailInfoViewModel.ProductCellViewModel?,
        _ dateViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?
    ) -> [OperationDetailInfoViewModel.TestCell] {
        
        OperationDetailInfoViewModel
            .makeItemsForTransport(
                dictionaryAnywayOperator: dictionaryAnywayOperator,
                operation,
                amountViewModel,
                commissionViewModel,
                payerViewModel,
                payeeViewModel,
                dateViewModel
            ).map(\.testCell)
    }

    private func makeSUT(
        transferEnum: OperationDetailData.TransferEnum?,
        detail: OperationDetailData? = nil,
        products: ProductsData = [:],
        currencyList: [CurrencyData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: OperationDetailInfoViewModel,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        model.products.value = products
        model.currencyList.value = currencyList
        model.images.value = ["1": .iconClose]
        let sut = OperationDetailInfoViewModel(
            model: model,
            operation: detail ?? makeOperationDetail(transferEnum: transferEnum),
            dismissAction: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private func makeOperationDetail(
        externalTransferType: OperationDetailData.ExternalTransferType? = nil,
        isTrafficPoliceService: Bool = false,
        transferEnum: OperationDetailData.TransferEnum? = nil,
        transferNumber: String? = nil,
        account: String? = nil,
        accountTitle: String? = nil,
        payeeFullName: String? = nil,
        payeePhone: String? = nil,
        productID: Int = 123,
        comment: String? = "Lorem ipsum dolor sit amet",
        operationStatus: OperationDetailData.OperationStatus = .complete,
        merchantSubName: String? = "merchantSubName",
        payeeAccountId: Int = 111,
        payeeBankName: String? = "ПАО СБЕРБАНК",
        memberId: String? = nil
    ) -> OperationDetailData {
        
        .stub(
            account: account,
            accountTitle: accountTitle,
            amount: 1111.0,
            claimId: "6e9f2bcf-5cfe-408a-b908-8babc48cb658",
            comment: comment,
            currencyAmount: "RUB",
            dateForDetail: "30 июня 2023, 12:32",
            externalTransferType: externalTransferType,
            isForaBank: false,
            isTrafficPoliceService: isTrafficPoliceService,
            memberId: memberId,
            operation: "Перевод юридическому лицу в сторонний банк",
            payeeAccountId: payeeAccountId,
            payeeAccountNumber: "40802810938050002771",
            payeeBankBIC: "044525225",
            payeeBankCorrAccount: "30101810400000000225",
            payeeBankName: "ПАО СБЕРБАНК",
            payeeCurrency: "RUB",
            payeeFullName: payeeFullName,
            payeeINN: nil,
            payeeKPP: nil,
            payeePhone: payeePhone,
            payerAccountId: 111,
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
            printFormType: .transport,
            puref: Purefs.iForaMosParking,
            requestDate: "30.06.2023 12:32:41",
            responseDate: "30.06.2023 12:33:28",
            returned: false,
            transferDate: "30.06.2023",
            transferEnum: transferEnum,
            transferNumber: transferNumber,
            cursivePayerAmount: "Одна тысяча сто сорок один рубль 00 копеек",
            cursiveAmount: "Одна тысяча сто одиннадцать рублей 00 копеек",
            merchantSubName: merchantSubName,
            merchantIcon: SVGImageData.test.description,
            operationStatus: operationStatus
        )
    }
    
    private func makeHistoryItemsForExternal(
        dictionaryFullBankInfoBank: @escaping (String) -> BankFullInfoData? = { _ in nil },
        _ type: OperationDetailData.ExternalTransferType,
        _ operation: OperationDetailData,
        _ amountViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ commissionViewModel: OperationDetailInfoViewModel.PropertyCellViewModel?,
        _ debitAccountViewModel: OperationDetailInfoViewModel.DefaultCellViewModel?,
        _ comment: String,
        _ dateString: String
    ) -> [OperationDetailInfoViewModel.TestCell] {
        
        OperationDetailInfoViewModel
            .makeHistoryItemsForExternal(
                dictionaryFullBankInfoBank: dictionaryFullBankInfoBank,
                type,
                operation,
                amountViewModel,
                commissionViewModel,
                debitAccountViewModel,
                comment,
                dateString).map(\.testCell)
    }
    
    private func makeProductStatementData(
        mcc: Int? = 1234,
        accountId: Int? = 12345,
        accountNumber: String = "1234567890",
        amount: Double = 100.0,
        cardTranNumber: String? = "1234567890123456",
        city: String? = "Test City",
        comment: String = "Test Comment",
        country: String? = "Test Country",
        currencyCodeNumeric: Int = 840,
        date: Date = Date(),
        deviceCode: String? = "TestDevice",
        documentAmount: Double? = 100.0,
        documentId: Int? = 12345,
        fastPayment: ProductStatementData.FastPayment? = .test,
        groupName: String = "Test Group Name",
        isCancellation: Bool? = true,
        md5hash: String = "testmd5hash",
        merchantName: String? = "Test Merchant Name",
        merchantNameRus: String? = "Тестовое Имя Продавца",
        opCode: Int? = 54321,
        operationId: String = "testoperationid",
        operationType: OperationType = .debit,
        paymentDetailType: ProductStatementData.Kind = .betweenTheir,
        svgImage: SVGImageData? = SVGImageData(description: "Test SVG Image"),
        terminalCode: String? = "testTerminalCode",
        tranDate: Date? = Date(),
        type: OperationEnvironment = .inside
    ) -> ProductStatementData {
        
        return ProductStatementData(
            mcc: mcc,
            accountId: accountId,
            accountNumber: accountNumber,
            amount: amount,
            cardTranNumber: cardTranNumber,
            city: city,
            comment: comment,
            country: country,
            currencyCodeNumeric: currencyCodeNumeric,
            date: date,
            deviceCode: deviceCode,
            documentAmount: documentAmount,
            documentId: documentId,
            fastPayment: fastPayment,
            groupName: groupName,
            isCancellation: isCancellation,
            md5hash: md5hash,
            merchantName: merchantName,
            merchantNameRus: merchantNameRus,
            opCode: opCode,
            operationId: operationId,
            operationType: operationType,
            paymentDetailType: paymentDetailType,
            svgImage: svgImage,
            terminalCode: terminalCode,
            tranDate: tranDate,
            type: type
        )
    }
    
    private func makeFastPayment(
        documentComment: String? = "Test FastPayment Comment",
        foreignBankBIC: String? = "044525491",
        foreignBankID: String? = "10000001153",
        foreignBankName: String? = "Test Foreign Bank Name",
        foreignName: String? = "Test Foreign Name",
        foreignPhoneNumber: String? = "70115110217",
        opkcid: String? = "A1355084612564010000057CAFC75755",
        operTypeFP: String? = "string",
        tradeName: String? = "Test Trade Name",
        guid: String? = "testguid"
    ) -> ProductStatementData.FastPayment {
        
        return ProductStatementData.FastPayment(
            documentComment: documentComment ?? "",
            foreignBankBIC: foreignBankBIC ?? "",
            foreignBankID: foreignBankID ?? "",
            foreignBankName: foreignBankName ?? "",
            foreignName: foreignName ?? "",
            foreignPhoneNumber: foreignPhoneNumber ?? "",
            opkcid: opkcid ?? "",
            operTypeFP: operTypeFP ?? "",
            tradeName: tradeName ?? "",
            guid: guid ?? ""
        )
    }
}

private extension OperationDetailInfoViewModel.DefaultCellViewModel {
    
    var testCell: OperationDetailInfoViewModel.TestCell { .init(self) }
}

private extension OperationDetailInfoViewModel {
    
    var testCells: [TestCell] { cells.map(\.testCell) }
    var testTitles: [String] { cells.map(\.title) }
    
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
    static let payeeName: Self = .property(title: "Наименование получателя", value: "ИП Домрачев Сергей Николаевич")
    static let payeeAccountNumber: Self = .property(title: "Номер счета получателя", value: "40802810938050002771")
    static let payeeBankBIC: Self = .bank(title: "Бик банка получателя", name: "044525225")
    static let payeeINN: Self = .property(title: "ИНН получателя", value: "772016190450")
    static let payeeKPP: Self = .property(title: "КПП получателя", value: "770801001")
    static let purpose: Self = .property(title: "Назначение платежа", value: "Lorem ipsum dolor sit amet")
    static let amount: Self = .property(title: "Amount", value: "1234")
    static let fee: Self = .property(title: "Fee", value: "345")
    static let payer: Self = .product(title: "payer", name: "Payer", balance: "9876", description: "PayerDescription")
    static let date: Self = .property(title: "Дата и время операции (МСК)", value: "30.06.2023 12:33:28")
    static let dateEmpty: Self = .property(title: "Дата и время операции (МСК)", value: "")
    static let commentEmpty: Self = .property(title: "Назначение платежа", value: "")
    static let payeeCardNumber: Self = .property(title: "Номер счета получателя",value: "44444")
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

private extension BankFullInfoData {
    
    static let bank: Self = .init(accountList: [.init(cbrbic: "044525000", account: "30101810145250000974", ck: "37", dateIn: "16.06.2016 00:00:00", dateOut: "16.06.2016 00:00:00", regulationAccountType: "CRSA", status: "ACAC")], address: "127287, г Москва, Ул. 2-я Хуторская, д.38А, стр.26", bankServiceType: "Сервис срочного перевода и сервис быстрых платежей", bankServiceTypeCode: "5", bankType: "20", bankTypeCode: "Кредитная организация", bic: "044525225", engName: "TINKOFF BANK", fiasId: "string", fullName: "АО \"ТИНЬКОФФ БАНК\"", inn: "string", kpp: "string", latitude: 0, longitude: 0, md5hash: "a97d3153c1172f0c5333c9eadb5696f3", memberId: "100000000004", name: "Tinkoff Bank", receiverList: ["string"], registrationDate: "16.06.2016 00:00:00", registrationNumber: "2673", rusName: "Тинькофф Банк", senderList: ["string"], svgImage: .init(description: "string"), swiftList: [.init(default: true, swift: "TICSRUMMXXX")])
}

private extension Model {
    
    var amount: String? { self.amountFormatted(amount: 1141, currencyCode: "RUB", style: .fraction) }
    var commission: String? { self.amountFormatted(amount: 30, currencyCode: "RUB", style: .fraction) }
}

private extension ProductStatementData {
    
    static func makeStatementData(
        fastPayment: FastPayment? = .test,
        paymentDetailType: ProductStatementData.Kind = .sfp,
        operationType: OperationType = .credit,
        foreignPhoneNumber: String = "70115110217",
        currencyCodeNumeric: Int = 810,
        isCancellation: Bool? = false,
        md5hash: String = "d46cb4ded97c143291ea3fab225b0e2f",
        documentId: Int? = 1,
        operationId: String = "1"
    ) -> ProductStatementData {
        
        return .init(
            mcc: nil,
            accountId: nil,
            accountNumber: "",
            amount: 20,
            cardTranNumber: nil,
            city: nil,
            comment: "",
            country: nil,
            currencyCodeNumeric: currencyCodeNumeric,
            date: Date(),
            deviceCode: nil,
            documentAmount: 20,
            documentId: documentId,
            fastPayment: fastPayment,
            groupName: "",
            isCancellation: isCancellation,
            md5hash: md5hash,
            merchantName: nil,
            merchantNameRus: nil,
            opCode: nil,
            operationId: operationId,
            operationType: operationType,
            paymentDetailType: paymentDetailType,
            svgImage: nil,
            terminalCode: nil,
            tranDate: nil,
            type: .inside
        )
    }
}

private extension ProductStatementData.FastPayment {

static let test: Self = .init(documentComment: "string", foreignBankBIC: "044525491", foreignBankID: "10000001153", foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"", foreignName: "Петров Петр Петрович", foreignPhoneNumber: "70115110217", opkcid: "A1355084612564010000057CAFC75755", operTypeFP: "string", tradeName: "string", guid: "string")
}
