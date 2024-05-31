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
    
    // MARK: - ParameterProduct
    
    func test_parameterProduct_withAdditionalFalse_shouldReturnC2BRules() {
    
        let parameterProduct = parameterProductStub(additional: false)
    
        XCTAssertNoDiff(parameterProduct.filter.rulesString, [
            .productTypeRule,
            .currencyRule,
            .cardAdditionalOwnedRestrictedRule,
            .cardAdditionalNotOwnedRestrictedRule,
            .productActiveRule
        ])
    }
    
    func test_parameterProduct_withAdditionalTrue_shouldReturnC2BRules() {

        let parameterProduct = parameterProductStub(additional: true)
    
        XCTAssertNoDiff(parameterProduct.filter.rulesString, [
            .productTypeRule,
            .currencyRule,
            .productActiveRule
        ])
    }
    
    func test_paymentsC2BReduceScenarioData_shouldReturnParameterSubscriber() {

        let sut = Model.emptyMock
        let parameter = try? sut.paymentsC2BReduceScenarioData(
            data: [.init(PaymentParameterSubscriber.stub())],
            c2b: .default
        ).first
        
        XCTAssertNoDiff(parameter?.id, "id")
    }
    
    // MARK: - Helpers
    
    private func parameterProductStub(
        additional: Bool
    ) -> Payments.ParameterProduct {
        
        Payments.ParameterProduct(
            with: .init(
                id: "id",
                value: nil,
                title: "title",
                filter: .init(
                    productTypes: [.account],
                    currencies: [.rub],
                    additional: additional
                )),
            product: .stub()
        )
    }
    
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

extension ProductData {
    
    static func cardStub(
        status: ProductData.Status = .active,
        statusPC: ProductData.StatusPC = .active
    ) -> ProductCardData {
        
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
            status: status,
            expireDate: nil,
            holderName: nil,
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: nil,
            statusPc: statusPC,
            isMain: nil,
            externalId: nil,
            order: 1,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: ""
        )
    }
    
    static func accountStub(
        status: ProductData.Status = .active
    ) -> ProductAccountData {
        
        ProductAccountData(
            id: 1,
            productType: .account,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "mainField",
            additionalField: nil,
            customName: "customName",
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
            background: [.init(description: "")],
            externalId: 1,
            name: "name",
            dateOpen: Date(),
            status: status,
            branchName: nil,
            miniStatement: [],
            order: 1,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            detailedRatesUrl: "",
            detailedConditionUrl: ""
        )
    }
}

private extension PaymentParameterSubscriber {
    
    static func stub() -> Self {
        .init(
            id: "id",
            value: "value",
            icon: "icon",
            legalName: "legalName",
            subscriptionPurpose: "subscriptionPurpose",
            style: .small
        )
    }
}

private extension ProductData.Filter {

    var rulesString: [FilterRules] {
        
        self.rules.map { filter in
                
            switch filter {
            case _ as ProductData.Filter.AccountActiveRule:
                return .accountActiveRule
            
            case _ as ProductData.Filter.ProductTypeRule:
                return .productTypeRule
            
            case _ as ProductData.Filter.CurrencyRule:
                return .currencyRule
            
            case _ as ProductData.Filter.CardAdditionalSelfAccOwnRule:
                return .cardAdditionalOwnedRestrictedRule
            
            case _ as ProductData.Filter.CardAdditionalSelfRule:
                return .cardAdditionalNotOwnedRestrictedRule
            
            case _ as ProductData.Filter.ProductActiveRule:
                return .productActiveRule
            
            default:
                return nil
            }
            
        }.compactMap( {$0} )
    }
    
    enum FilterRules: Equatable {
        case accountActiveRule,
             productTypeRule,
             currencyRule,
             cardAdditionalOwnedRestrictedRule,
             cardAdditionalNotOwnedRestrictedRule,
             productActiveRule
    }
}
