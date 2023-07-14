//
//  PaymentsMeToMeViewModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 21.06.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsMeToMeViewModelTests: XCTestCase {

    let templateId = 1
    let oldName = "oldName"
    
    func test_paymentMeToMe_bindRename_shouldSetTitle() throws {

        let model = modelWithNecessaryData()
        let newName = "newName"
        
        let sut = makeSUT(model: model)
        
        let renameViewModel = TemplatesListViewModel.RenameTemplateItemViewModel(
            oldName: oldName, templateID: templateId)
        sut?.bindRename(rename: renameViewModel)
        
        renameViewModel.action.send(TemplatesListViewModelAction.RenameSheetAction.SaveNewName(
            newName: newName,
            itemId: 1
        ))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertEqual(sut?.title, newName)
        XCTAssertNil(sut?.bottomSheet)
    }
    
    func test_paymentMeToMe_renameBottomSheet_shouldSetBottomSheet() throws {
        
        let model = modelWithNecessaryData()
        
        let sut = makeSUT(model: model)
        
        let title = try XCTUnwrap(sut?.title)
        
        sut?.renameBottomSheet(
            oldName: title,
            templateId: templateId
        )
        
        XCTAssertNotNil(sut?.bottomSheet)
    }
}

extension PaymentsMeToMeViewModelTests {

    func modelWithNecessaryData() -> Model {
        
        let model = Model.mockWithEmptyExcept()
        model.paymentTemplates.value.append(.templateStub(
            paymentTemplateId: templateId,
            type: .betweenTheir,
            parameterList: TransferGeneralData.generalStub())
        )
        
        model.products.value = [.card: [ProductData.stub(productId: 1)]]
        
        return model
    }
    
    func makeSUT(
        model: Model,
        templateId: PaymentTemplateData.ID = 1
    ) -> PaymentsMeToMeViewModel? {
        
        let name = model.paymentTemplates.value.first(where: { $0.id == templateId })?.name
        let sut = PaymentsMeToMeViewModel(
            model,
            mode: .templatePayment(templateId, name ?? "Между своими")
        )
        
        return sut
    }
}

extension ProductData {
    
    //TODO: remove stub after merge DBSNEW-8883
    static func stub(productId: Int = UUID().hashValue) -> ProductData {
        
        return .init(
            id: productId,
            productType: .card,
            number: "1",
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "Rub",
            mainField: "",
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
            background: [.init(description: "")],
            order: 1,
            isVisible: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: ""
        )
    }
}
