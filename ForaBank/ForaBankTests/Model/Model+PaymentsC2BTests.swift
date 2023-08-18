//
//  Model+PaymentsC2BTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 18.08.2023.
//

@testable import ForaBank
import XCTest

final class Model_PaymentsC2BTests: XCTestCase {
    
    func test_getC2bPayloadParameters_withAmount_amountCompleteTrue_shouldReturnC2bParameters() {
        
        let sut = makeSUT()
        
        let payloadParameters = getC2bPayloadParameters(
            model: sut,
            amountValue: "10",
            amountComplete: true
        )
        
        XCTAssertNoDiff(payloadParameters.map(\.id), [
            "qrcId",
            "debit_account"
        ])
    }
    
    func test_getC2bPayloadParameters_withAmount_amountCompleteFalse_shouldReturnC2bParameters() {
        
        let sut = makeSUT()
        
        let payloadParameters = getC2bPayloadParameters(
            model: sut,
            amountValue: "10",
            amountComplete: false
        )
        
        XCTAssertNoDiff(payloadParameters.map(\.id), [
            "qrcId",
            "debit_account",
            "payment_amount",
            "currency"
        ])
    }
    
    func test_getC2bPayloadParameters_withAmountNil_amountCompleteFalse_shouldReturnC2bParameters() {
        
        let sut = makeSUT()
        
        let payloadParameters = getC2bPayloadParameters(
            model: sut,
            amountValue: nil,
            amountComplete: false
        )
        
        XCTAssertNoDiff(payloadParameters.map(\.id), [
            "qrcId",
            "debit_account"
        ])
    }
    
    // MARK: - Helpers
    
    private func getC2bPayloadParameters(
        model: Model,
        amountValue: String?,
        amountComplete: Bool
    ) -> [PaymentC2BParameter] {
        
        return model.getC2bPayloadParameters(
            "qrcid",
            c2bOperationWithParameter(amountValue: amountValue, amountComplete: amountComplete),
            .cardStub()
        )
    }
    
    private func c2bOperationWithParameter(
        amountValue: String?,
        amountComplete: Bool
    ) -> Payments.Operation {
        
        let parameters: [PaymentsParameterRepresentable] = [
            Payments.ParameterMock(id: Payments.Parameter.Identifier.product.rawValue, value: "1"),
            Payments.ParameterMock(id: Payments.Parameter.Identifier.c2bIsAmountComplete.rawValue, value: amountComplete.description),
            Payments.ParameterAmount(
                value: amountValue,
                title: "",
                currencySymbol: "",
                validator: .init(minAmount: 0, maxAmount: 10)
            )
        ]
        
        return .init(
            service: .c2b,
            source: .c2b(anyURL()),
            steps: [
                .init(
                    parameters: parameters,
                    front: .init(
                        visible: [],
                        isCompleted: true
                    ),
                    back: .init(
                        stage: .remote(.complete),
                        required: [],
                        processed: [])
                )
            ],
            visible: [])
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        let sut: Model = .mockWithEmptyExcept()
        
        sut.products.value = [.card : [.cardStub()]]
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension ProductData {
    
    static func cardStub() -> ProductCardData{
        
        ProductCardData(
            id: 1,
            productType: .card,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "mainField",
            additionalField: nil,
            customName: nil,
            productName: "productName",
            openDate: nil,
            ownerId: 1,
            branchId: nil,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: ""),
            background: [],
            accountId: nil,
            cardId: 1,
            name: "name",
            validThru: .init(),
            status: .active,
            expireDate: nil,
            holderName: nil,
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: nil,
            statusPc: .active,
            isMain: nil,
            externalId: nil,
            order: 1,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: ""
        )
    }
}
