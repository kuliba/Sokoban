//
//  InfoProductViewModelTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 20.06.2023.
//

import Foundation

import XCTest
@testable import ForaBank

final class InfoProductViewModelTests: XCTestCase {
    
    typealias DocumentItemModel = InfoProductViewModel.DocumentItemModel
    typealias ItemViewModelWithAction = InfoProductViewModel.ItemViewModelWithAction
    typealias ItemViewModelForList = InfoProductViewModel.ItemViewModelForList
    typealias ItemViewModel = InfoProductViewModel.ItemViewModel
    
    //MARK: - test init InfoProductViewModel
    
    func test_init_infoProductViewModel_shouldSetAllValue() {
        
        let product = anyProduct(id: 0, productType: .card)
        let sut = makeSUT(product: product)
        
        XCTAssertNoDiff(sut.product, product)
        XCTAssertNoDiff(sut.title, .title)
        XCTAssertNoDiff(sut.list, .items)
        XCTAssertNoDiff(sut.listWithAction, .items)
        XCTAssertNoDiff(sut.additionalList, .cardItems)
    }
    
    //MARK: - test init ItemViewModel
    
    func test_init_itemViewModel_shouldSetAllValue() {
        
        let item: ItemViewModel = .init(
            title: "title",
            subtitle: "subtitle"
        )
        
        XCTAssertNoDiff(item.title, "title")
        XCTAssertNoDiff(item.subtitle, "subtitle")
    }
    
    //MARK: - test isDisableShareButton
    
    func test_isDisableShareButton_needShowCheckboxFalse_shouldFalse() {
        
        let sut = makeSUT()
        
        XCTAssertFalse(sut.needShowCheckbox)
        XCTAssertFalse(sut.isDisableShareButton)
    }
    
    func test_isDisableShareButton_needShowCheckboxTrueNotSelectedBlock_shouldFalse() {
        
        let sut = makeSUT()
        
        XCTAssertFalse(sut.needShowCheckbox)
        
        sut.needShowCheckbox = true
        
        XCTAssertTrue(sut.needShowCheckbox)
        XCTAssertFalse(sut.accountInfoSelected)
        XCTAssertFalse(sut.cardInfoSelected)
        
        XCTAssertTrue(sut.isDisableShareButton)
    }
    
    func test_isDisableShareButton_needShowCheckboxTrueSelectedAccountBlock_shouldTrue() {
        
        let sut = makeSUT()
        
        XCTAssertFalse(sut.needShowCheckbox)
        
        sut.needShowCheckbox = true
        
        XCTAssertTrue(sut.needShowCheckbox)
        XCTAssertFalse(sut.accountInfoSelected)
        XCTAssertFalse(sut.cardInfoSelected)
        XCTAssertTrue(sut.isDisableShareButton)
        
        sut.accountInfoSelected = true
        
        XCTAssertTrue(sut.accountInfoSelected)
        XCTAssertFalse(sut.cardInfoSelected)
        XCTAssertFalse(sut.isDisableShareButton)
    }
    
    func test_isDisableShareButton_needShowCheckboxTrueSelectedCardBlock_shouldTrue() {
        
        let sut = makeSUT()
        
        XCTAssertFalse(sut.needShowCheckbox)
        
        sut.needShowCheckbox = true
        
        XCTAssertTrue(sut.needShowCheckbox)
        XCTAssertFalse(sut.accountInfoSelected)
        XCTAssertFalse(sut.cardInfoSelected)
        XCTAssertTrue(sut.isDisableShareButton)
        
        sut.cardInfoSelected = true
        
        XCTAssertFalse(sut.accountInfoSelected)
        XCTAssertTrue(sut.cardInfoSelected)
        XCTAssertFalse(sut.isDisableShareButton)
    }
    
    //MARK: - test set needShowCheckBox
    
    func test_needShowCheckbox_setFalse_shouldSetAccountInfoSelectedFalse() {
        
        let sut = makeSUT()
        
        XCTAssertFalse(sut.accountInfoSelected)
        XCTAssertFalse(sut.needShowCheckbox)
        
        sut.needShowCheckbox.toggle()
        sut.accountInfoSelected.toggle()
        
        XCTAssertTrue(sut.accountInfoSelected)
        XCTAssertTrue(sut.needShowCheckbox)
        
        sut.needShowCheckbox.toggle()
        
        XCTAssertFalse(sut.accountInfoSelected)
        XCTAssertFalse(sut.needShowCheckbox)
    }
    
    func test_needShowCheckbox_setFalse_shouldSetCardInfoSelectedFalse() {
        
        let sut = makeSUT()
        
        XCTAssertFalse(sut.cardInfoSelected)
        XCTAssertFalse(sut.needShowCheckbox)
        
        sut.needShowCheckbox.toggle()
        sut.cardInfoSelected.toggle()
        
        XCTAssertTrue(sut.cardInfoSelected)
        XCTAssertTrue(sut.needShowCheckbox)
        
        sut.needShowCheckbox.toggle()
        
        XCTAssertFalse(sut.cardInfoSelected)
        XCTAssertFalse(sut.needShowCheckbox)
    }
    
    //MARK: - test makeItemViewModel
    
    func test_makeItemViewModel_shouldSetAllValueIconNil() {
        
        let item = InfoProductViewModel.makeItemViewModel(
            from: .accountNumber,
            with: {_,_ in })
        
        let documentItemModel = DocumentItemModel.accountNumber
        
        XCTAssertNoDiff(item.title, documentItemModel.title)
        XCTAssertNoDiff(item.subtitle, documentItemModel.subtitle)
        XCTAssertNoDiff(item.id, documentItemModel.id)
        XCTAssertNotNil(item.actionForLongPress)
        XCTAssertNil(item.icon)
    }
    
    func test_makeItemViewModel_shouldSetAllValueIconNotNil() {
        
        let item = InfoProductViewModel.makeItemViewModel(
            from: .number,
            with: {_,_ in })
        
        let documentItemModel = DocumentItemModel.number
        
        XCTAssertNoDiff(item.title, documentItemModel.title)
        XCTAssertNoDiff(item.subtitle, documentItemModel.subtitle)
        XCTAssertNoDiff(item.id, documentItemModel.id)
        XCTAssertNotNil(item.actionForLongPress)
        XCTAssertNotNil(item.icon)
    }
    
    //MARK: - test ItemViewModelWithAction
    
    func test_init_itemViewModelWithAction_shouldSetAllValue() {
        
        let item: ItemViewModelWithAction = .init(
            id: .accountNumber,
            title: "title",
            titleForInformer: "titleForInformer",
            subtitle: "subtitle",
            valueForCopy: "valueForCopy",
            actionForLongPress: { _,_ in },
            actionForIcon: {})
        
        XCTAssertNoDiff(item.id, .accountNumber)
        XCTAssertNoDiff(item.title, "title")
        XCTAssertNoDiff(item.titleForInformer, "titleForInformer")
        XCTAssertNoDiff(item.subtitle, "subtitle")
        XCTAssertNoDiff(item.valueForCopy, "valueForCopy")
        XCTAssertNotNil(item.actionForLongPress)
        XCTAssertNotNil(item.actionForIcon)
    }
    
    func test_equatable_hashable_itemViewModelWithAction() {
        
        let itemOne: ItemViewModelWithAction = .init(
            id: .accountNumber,
            title: "title",
            titleForInformer: "titleForInformer",
            subtitle: "subtitle",
            valueForCopy: "valueForCopy",
            actionForLongPress: { _,_ in },
            actionForIcon: {})
        
        let itemTwo: ItemViewModelWithAction = .init(
            id: .accountNumber,
            title: "title",
            titleForInformer: "titleForInformer",
            subtitle: "subtitle",
            valueForCopy: "valueForCopy",
            actionForLongPress: { _,_ in },
            actionForIcon: {})
        
        XCTAssertEqual(itemOne == itemTwo, true)
        XCTAssertNoDiff(itemOne.hashValue, itemTwo.hashValue)
    }
    
    //MARK: - test ItemViewModelForList
    
    func test_init_itemViewModelForList_single_shouldSetAllValue() {
        
        let item: ItemViewModelForList = .single(
            .init(
                id: .accountNumber,
                title: "title",
                titleForInformer: "titleForInformer",
                subtitle: "subtitle",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        )
        
        XCTAssertEqual(item.currentValues.count, 1)
        
        let value = item.currentValues.first!
        
        XCTAssertNoDiff(value.id, .accountNumber)
        XCTAssertNoDiff(value.title, "title")
        XCTAssertNoDiff(value.titleForInformer, "titleForInformer")
        XCTAssertNoDiff(value.subtitle, "subtitle")
        XCTAssertNoDiff(value.valueForCopy, "valueForCopy")
        XCTAssertNotNil(value.actionForLongPress)
        XCTAssertNotNil(value.actionForIcon)
        XCTAssertNoDiff(item.currentValueString, .stringForSingle)
    }
    
    func test_equatable_hashable_single_itemViewModelForList() {
        
        let itemOne: ItemViewModelForList = .single(
            .init(
                id: .accountNumber,
                title: "title",
                titleForInformer: "titleForInformer",
                subtitle: "subtitle",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        )
        
        let itemTwo: ItemViewModelForList = .single(
            .init(
                id: .accountNumber,
                title: "title",
                titleForInformer: "titleForInformer",
                subtitle: "subtitle",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        )
        
        XCTAssertEqual(itemOne == itemTwo, true)
        XCTAssertNoDiff(itemOne.hashValue, itemTwo.hashValue)
    }
    
    func test_init_itemViewModelForList_multiple_shouldSetAllValue() {
        
        let values: [ItemViewModelWithAction] = .itemsForMultiple
        let itemViewModelForList: ItemViewModelForList = .multiple(
            values
        )
        
        XCTAssertEqual(itemViewModelForList.currentValues.count, values.count)
        
        for (index, element) in itemViewModelForList.currentValues.enumerated() {
            
            XCTAssertNoDiff(element.title, values[index].title)
            XCTAssertNoDiff(element.subtitle, values[index].subtitle)
            XCTAssertNoDiff(element.id, values[index].id)
            XCTAssertNotNil(element.actionForLongPress)
        }
        XCTAssertNoDiff(itemViewModelForList.currentValueString, .stringForMultiple)
    }
    
    func test_equatable_hashable_multiple_itemViewModelForList() {
        
        let items: [ItemViewModelWithAction] = .itemsForMultiple
        
        let itemOne: ItemViewModelForList = .multiple(
            items
        )
        
        let itemTwo: ItemViewModelForList = .multiple(
            items
        )
        
        XCTAssertEqual(itemOne == itemTwo, true)
        XCTAssertNoDiff(itemOne.hashValue, itemTwo.hashValue)
    }
    
    //MARK: - test cvv
    
    func test_init_cvv_shouldSetEmptyCurrentValueString() {
        
        let item: ItemViewModelForList = .single(
            .init(
                id: .cvv,
                title: "title",
                titleForInformer: "titleForInformer",
                subtitle: "subtitle",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        )
        
        XCTAssertEqual(item.currentValues.count, 1)
        
        XCTAssertNoDiff(item.currentValueString, "")
    }
    
    func test_init_cvvMasked_shouldSetEmptyCurrentValueString() {
        
        let item: ItemViewModelForList = .single(
            .init(
                id: .cvvMasked,
                title: "title",
                titleForInformer: "titleForInformer",
                subtitle: "subtitle",
                valueForCopy: "valueForCopy",
                actionForLongPress: { _,_ in },
                actionForIcon: {}
            )
        )
        
        XCTAssertEqual(item.currentValues.count, 1)
        
        XCTAssertNoDiff(item.currentValueString, "")
    }
    
    //MARK: - test makeItemViewModelSingle
    
    func test_makeItemViewModelSingle_shouldSetAllValue() {
        
        let item = InfoProductViewModel.makeItemViewModelSingle(
            from: .accountNumber,
            with: {_,_ in })
        
        let documentItemModel = DocumentItemModel.accountNumber
        
        XCTAssertNoDiff(item.currentValues.count, 1)
        
        let value = item.currentValues.first!
        
        XCTAssertNoDiff(value.title, documentItemModel.title)
        XCTAssertNoDiff(value.subtitle, documentItemModel.subtitle)
        XCTAssertNoDiff(value.id, documentItemModel.id)
        XCTAssertNoDiff(value.valueForCopy, documentItemModel.valueForCopy)
        XCTAssertNotNil(value.actionForLongPress)
        XCTAssertNotNil(value.actionForIcon)
    }
    
    func test_makeItemViewModelSingleWithIconAction_shouldSetAllValue() {
        
        let item = InfoProductViewModel.makeItemViewModelSingle(
            from: .accountNumber,
            with: {_,_ in },
            actionForIcon: {}
        )
        
        let documentItemModel = DocumentItemModel.accountNumber
        
        XCTAssertNoDiff(item.currentValues.count, 1)
        
        let value = item.currentValues.first!
        
        XCTAssertNoDiff(value.title, documentItemModel.title)
        XCTAssertNoDiff(value.subtitle, documentItemModel.subtitle)
        XCTAssertNoDiff(value.id, documentItemModel.id)
        XCTAssertNoDiff(value.valueForCopy, documentItemModel.valueForCopy)
        XCTAssertNotNil(value.actionForLongPress)
        XCTAssertNotNil(value.actionForIcon)
    }
    
    //MARK: - test makeItemViewModelMultiple
    
    func test_makeItemViewModelMultiple_shouldSetAllValue() {
        
        let values: [DocumentItemModel] = [.inn, .kpp]
        let items = InfoProductViewModel.makeItemViewModelMultiple(
            from: values,
            with: {_,_ in })
        
        XCTAssertNoDiff(items.currentValues.count, values.count)
        
        for (index, element) in items.currentValues.enumerated() {
            
            XCTAssertNoDiff(element.title, values[index].title)
            XCTAssertNoDiff(element.subtitle, values[index].subtitle)
            XCTAssertNoDiff(element.id, values[index].id)
            XCTAssertNoDiff(element.valueForCopy, values[index].valueForCopy)
            
            XCTAssertNotNil(element.actionForLongPress)
        }
    }
    
    //MARK: - test reduceSingle for Account
    
    func test_reduceSingle_account_shouldSetAllValue() {
        
        let items = InfoProductViewModel.reduceSingle(data: .productDetailsData)
        let documentItems: [DocumentItemModel] = .documentItemsSingle
        
        XCTAssertEqual(Set(items.map(\.id)), Set(documentItems.map(\.id)))
    }
    
    func test_reduceSingle_account_fullData_shouldSetAllValue() {
        
        let items = InfoProductViewModel.reduceSingle(data: .productDetailsDataFull)
        let documentItems: [DocumentItemModel] = .documentItemsSingle
        
        XCTAssertEqual(Set(items.map(\.id)), Set(documentItems.map(\.id)))
    }
    
    //MARK: - test reduceSingle for Card
    
    func test_reduceSingle_card_shouldSetEmptyIfDataNil() {
        
        let items = InfoProductViewModel.reduceSingle(
            data: InfoProductViewModelTests.productCardData,
            needShowFullNumber: true
        )
        
        XCTAssertTrue(items.isEmpty)
    }
    
    func test_reduceSingle_card_fullData_shouldSetAllValue() {
        
        let items = InfoProductViewModel.reduceSingle(
            data: InfoProductViewModelTests.productCardDataFull,
            needShowFullNumber: true
        )
        let documentItems: [DocumentItemModel] = .cardItemsSingle
        
        XCTAssertEqual(Set(items.map(\.id)), Set(documentItems.map(\.id)))
    }
    
    func test_reduceSingle_card_containOnlyNumberIfNeedShowFullNumberTrue() {
        
        let items = InfoProductViewModel.reduceSingle(
            data: InfoProductViewModelTests.productCardDataFull,
            needShowFullNumber: true
        )
        
        XCTAssertTrue(Set(items.map(\.id)).contains(.number))
        XCTAssertFalse(Set(items.map(\.id)).contains(.numberMasked))
    }
    
    func test_reduceSingle_card_containOnlyNumberMaskedIfNeedShowFullNumberFalse() {
        
        let items = InfoProductViewModel.reduceSingle(
            data: InfoProductViewModelTests.productCardDataFull,
            needShowFullNumber: false
        )
        
        XCTAssertTrue(Set(items.map(\.id)).contains(.numberMasked))
        XCTAssertFalse(Set(items.map(\.id)).contains(.number))
    }
    
    //MARK: - test reduceMultiple for account
    
    func test_reduceMultiple_shouldSetAllValue() {
        
        let items = InfoProductViewModel.reduceMultiple(data: .productDetailsData)
        let documentItems: [DocumentItemModel] = .documentItemsMultiple
        
        XCTAssertEqual(Set(items.map(\.id)), Set(documentItems.map(\.id)))
    }
    
    func test_reduceMultiple_fullData_shouldSetAllValue() {
        
        let items = InfoProductViewModel.reduceMultiple(data: .productDetailsDataFull)
        let documentItems: [DocumentItemModel] = .documentItemsMultiple
        
        XCTAssertEqual(Set(items.map(\.id)), Set(documentItems.map(\.id)))
    }
    
    //MARK: - test reduceMultiple for card
    
    func test_reduceMultiple_card_shouldSetEmptyIfDataNil() {
        
        let items = InfoProductViewModel.reduceMultiple(
            data: InfoProductViewModelTests.productCardData,
            needShowCvv: false
        )
        
        XCTAssertTrue(items.isEmpty)
    }
    
    func test_reduceMultiple_card_shouldSetAllValue() {
        
        let items =  InfoProductViewModel.reduceMultiple(
            data: InfoProductViewModelTests.productCardDataFull,
            needShowCvv: true
        )
        let documentItems: [DocumentItemModel] = .cardItemsMultiple
        
        XCTAssertEqual(Set(items.map(\.id)), Set(documentItems.map(\.id)))
    }
    
    func test_reduceMultiple_card_containOnlyCvvMaskedIfNeedShowCvvFalse() {
        
        let items = InfoProductViewModel.reduceMultiple(
            data: InfoProductViewModelTests.productCardDataFull,
            needShowCvv: false
        )
        
        XCTAssertTrue(Set(items.map(\.id)).contains(.cvvMasked))
        XCTAssertFalse(Set(items.map(\.id)).contains(.cvv))
    }
    
    func test_reduceMultiple_card_containOnlyCvvIfNeedShowCvvTrue() {
        
        let items = InfoProductViewModel.reduceMultiple(
            data: InfoProductViewModelTests.productCardDataFull,
            needShowCvv: true
        )
        
        XCTAssertTrue(Set(items.map(\.id)).contains(.cvv))
        XCTAssertFalse(Set(items.map(\.id)).contains(.cvvMasked))
    }
    
    //MARK: - test ModelAction.Deposits.Info.Single.Response
    
    func test_modelAction_shouldNotChangeListOnDepositeInfoResponseFail() {
        
        let (sut, model) = makeSUT1(product: .firstValue())
        let spy = ValueSpy(sut.$list)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.title) }, [
            []
        ])
        
        let response = ResponseDeposits.failure(message: "Error")
        
        model.action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.title) }, [
            []
        ])
    }
    
    func test_modelAction_shouldChangeListOnDepositeInfoResponseSuccess() {
        
        let (sut, model) = makeSUT1(product: .firstValue())
        let spy = ValueSpy(sut.$list)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.title) }, [
            []
        ])
        
        let response = ResponseDeposits.success(data: .data)
        model.action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(Set(spy.values.map { $0.map(\.title) }), [[], .depositeTitles])
    }
    
    func test_modelAction_shouldNotChangeListfIfIdOther() {
        
        let (sut, model) = makeSUT1(product: .firstValue())
        let spy = ValueSpy(sut.$list)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.title) }, [
            []
        ])
        
        let response = ResponseDeposits.success(data: .dataOtherId)
        
        model.action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.title) }, [
            []
        ])
    }
    
    //MARK: - test ModelAction.Products.ProductDetails
    
    func test_modelAction_shouldNotChangeListOnProductDetailsInfoResponseFail() {
        
        let (sut, model) = makeSUT1(product: .firstValue())
        let spy = ValueSpy(sut.$listWithAction)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.currentValueString) }, [
            []
        ])
        
        let response = ResponseProductDetails.failure(message: "Error")
        
        model.action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.currentValueString) }, [
            []
        ])
    }
    
    func test_modelAction_shouldChangeListOnProductDetailsInfoResponseSuccess() {
        
        let (sut, model) = makeSUT1(product: .firstValue())
        let spy = ValueSpy(sut.$listWithAction)
        
        XCTAssertNoDiff(spy.values.map { $0.map(\.currentValues) }, [
            []
        ])
        
        let response = ResponseProductDetails.success(productDetails: .data)
        model.action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let result = spy.values.map{
            $0.map(\.currentValueString)
        }
        
        XCTAssertNoDiff(result, [[], .cardInfo])
    }
    
    //MARK: - test InfoProductModelAction
    
    func test_action_shouldCardNumberToggle() throws {
        
        let sut = makeSUT(card: InfoProductViewModelTests.productCardDataFull)
        
        let cardInfo = try XCTUnwrap(sut.additionalList)
        let items = arrayOfIds(items: cardInfo)
        
        XCTAssertTrue(items.contains(.numberMasked))
        XCTAssertFalse(items.contains(.number))
        
        sut.action.send(InfoProductModelAction.ToogleCardNumber(productCardData: InfoProductViewModelTests.productCardDataFull))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let cardInfoNew = try XCTUnwrap(sut.additionalList)
        
        let itemsNew = arrayOfIds(items: cardInfoNew)
        
        XCTAssertTrue(itemsNew.contains(.number))
        XCTAssertFalse(itemsNew.contains(.numberMasked))
    }
    
    func test_action_shouldCvvToogle() throws {
        
        let sut = makeSUT(card: InfoProductViewModelTests.productCardDataFull)
        
        let cardInfo = try XCTUnwrap(sut.additionalList)
        let items = arrayOfIds(items: cardInfo)
        
        XCTAssertTrue(items.contains(.cvvMasked))
        XCTAssertFalse(items.contains(.cvv))
        
        sut.action.send(InfoProductModelAction.ToogleCVV(productCardData: InfoProductViewModelTests.productCardDataFull))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let cardInfoNew = try XCTUnwrap(sut.additionalList)
        
        let itemsNew = arrayOfIds(items: cardInfoNew)
        
        XCTAssertTrue(itemsNew.contains(.cvv))
        XCTAssertFalse(itemsNew.contains(.cvvMasked))
    }
    
    func test_action_default_shouldNothingChanged() throws {
        
        let sut = makeSUT(card: InfoProductViewModelTests.productCardDataFull)
        
        let cardInfo = try XCTUnwrap(sut.additionalList)
        let items = arrayOfIds(items: cardInfo)
        
        XCTAssertTrue(items.contains(.numberMasked))
        XCTAssertFalse(items.contains(.number))
        XCTAssertTrue(items.contains(.cvvMasked))
        XCTAssertFalse(items.contains(.cvv))
        
        let response = ResponseDeposits.success(data: .dataOtherId)
        
        sut.action.send(response)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let cardInfoNew = try XCTUnwrap(sut.additionalList)
        
        let itemsNew = arrayOfIds(items: cardInfoNew)
        
        XCTAssertTrue(itemsNew.contains(.numberMasked))
        XCTAssertFalse(itemsNew.contains(.number))
        XCTAssertTrue(items.contains(.cvvMasked))
        XCTAssertFalse(items.contains(.cvv))
    }
    
    func test_action_shouldCvvToogleAfterNumberToogle() throws {
        
        let sut = makeSUT(card: InfoProductViewModelTests.productCardDataFull)
        
        let cardInfoOld = try XCTUnwrap(sut.additionalList)
        let itemsOld = arrayOfIds(items: cardInfoOld)
        
        XCTAssertTrue(itemsOld.contains(.cvvMasked))
        XCTAssertFalse(itemsOld.contains(.cvv))
        XCTAssertTrue(itemsOld.contains(.numberMasked))
        XCTAssertFalse(itemsOld.contains(.number))
        
        sut.action.send(InfoProductModelAction.ToogleCVV(productCardData: InfoProductViewModelTests.productCardDataFull))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let cardInfo = try XCTUnwrap(sut.additionalList)
        let items = arrayOfIds(items: cardInfo)
        
        XCTAssertTrue(items.contains(.cvv))
        XCTAssertFalse(items.contains(.cvvMasked))
        XCTAssertTrue(items.contains(.numberMasked))
        XCTAssertFalse(items.contains(.number))
        
        sut.action.send(InfoProductModelAction.ToogleCardNumber(productCardData: InfoProductViewModelTests.productCardDataFull))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        let cardInfoNew = try XCTUnwrap(sut.additionalList)
        
        let itemsNew = arrayOfIds(items: cardInfoNew)
        
        XCTAssertTrue(itemsNew.contains(.cvvMasked))
        XCTAssertFalse(itemsNew.contains(.cvv))
        XCTAssertTrue(itemsNew.contains(.number))
        XCTAssertFalse(itemsNew.contains(.numberMasked))
    }
    
    //MARK: - test copyValue
    
    func test_copyValue() {
        
        let sut = makeSUT()
        
        sut.copyValue(
            value: "text for copy",
            titleForInformer: "text"
        )
        
        let result = UIPasteboard.general.string
        
        XCTAssertNoDiff(result, "text for copy")
    }
    
    //MARK: - test itemsToString
    
    func test_itemsToString() {
        
        let sut = makeSUT()
        let cardInfo: [ItemViewModelForList] = .cardItems
        let items: [ItemViewModel] = .items
        
        let result = sut.itemsToString(items: [items, cardInfo])
        
        XCTAssertNoDiff(result, .stringForShare)
    }
    
    //MARK: - test dataForShare
    
    func test_dataForShare_All() {
        
        let sut = makeSUT(product: .firstValue())
        let list = sut.list
        let listWithAction = sut.listWithAction
        let additionallist = sut.additionalList
        
        XCTAssertFalse(sut.needShowCheckbox)
        
        XCTAssertNotNil(list)
        XCTAssertNotNil(listWithAction)
        XCTAssertNotNil(additionallist)
        
        let result = sut.dataForShare
        
        XCTAssertNoDiff(result.count, 3)
    }
    
    func test_dataForShare_withOutAdditional() {
        
        let sut = makeSUT(product: .firstValue())
        let list = sut.list
        let listWithAction = sut.listWithAction
        let additionallist = sut.additionalList
        
        XCTAssertNotNil(list)
        XCTAssertNotNil(listWithAction)
        XCTAssertNotNil(additionallist)
        
        sut.needShowCheckbox = true
        sut.accountInfoSelected = true
        sut.cardInfoSelected = false
        
        let result = sut.dataForShare
        
        XCTAssertNoDiff(result.count, 2)
    }
    
    func test_dataForShare_withListWithAction() {
        
        let sut = makeSUT(product: .firstValue())
        let list = sut.list
        let listWithAction = sut.listWithAction
        let additionallist = sut.additionalList
        
        XCTAssertNotNil(list)
        XCTAssertNotNil(listWithAction)
        XCTAssertNotNil(additionallist)
        
        sut.needShowCheckbox = true
        sut.cardInfoSelected = true
        sut.accountInfoSelected = false
        
        let result = sut.dataForShare
        
        XCTAssertNoDiff(result.count, 2)
    }
    
    func test_dataForShare_onlyList() {
        
        let sut = makeSUT(product: .firstValue())
        let list = sut.list
        let listWithAction = sut.listWithAction
        let additionallist = sut.additionalList
        
        XCTAssertNotNil(list)
        XCTAssertNotNil(listWithAction)
        XCTAssertNotNil(additionallist)
        
        sut.needShowCheckbox = true
        sut.cardInfoSelected = false
        sut.accountInfoSelected = false
        
        let result = sut.dataForShare
        
        XCTAssertNoDiff(result.count, 1)
    }
    
    ///
    // MARK: - Test Data
    
    func test_moscowTime_sameTimeZone_returnsSelf() {
        
        let moscowTimeZone = TimeZone(identifier: "Europe/Moscow")!
        let moscowDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
        
        let moscowTime = moscowDate?.moscowTime
        
        XCTAssertEqual(moscowTime, moscowDate)
    }
    
    
    func testMoscowTimeForInvalidTimezoneIdentifier() {
        
        let invalidTimezoneIdentifier = "Invalid/Timezone"
        let originalDate = Date()
        
        guard let invalidTimeZone = TimeZone(identifier: invalidTimezoneIdentifier) else {
            
            let invalidTimezoneDate = originalDate.moscowTime
            XCTAssertEqual(invalidTimezoneDate, originalDate, "moscowTime should return the original date if the timezone identifier is invalid")
            return
        }
        
        XCTFail("Expected an invalid timezone, but a valid one was created")
    }
    
    func testMoscowTimeForDateInMoscowTimezone() {
        
        let moscowTime: Date = .testDateInMoscowTimezone.moscowTime
        
        XCTAssertEqual(moscowTime, .expectedMoscowTime, "moscowTime should be equal to the expected value for a date in the Moscow timezone")
    }
    
    // MARK: - Helpers
    
    typealias ResponseDeposits = ModelAction.Deposits.Info.Single.Response
    
    typealias ResponseProductDetails = ModelAction.Products.ProductDetails.Response
    
    func makeSUT(
        model: Model = .mockWithEmptyExcept(),
        product: ProductData,
        file: StaticString = #file,
        line: UInt = #line
    )
    -> InfoProductViewModel {
        
        let sut: InfoProductViewModel = .init(
            product: product,
            title: .title,
            list: .items,
            listWithAction: .items,
            additionalList: .cardItems,
            shareButton: .shareButton,
            model: model)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func makeSUT(
        card: ProductCardData
    )
    -> InfoProductViewModel {
        
        let model: Model = .mockWithEmptyExcept()
        
        let sut: InfoProductViewModel = .init(
            model: model,
            product: card
        )
        //TODO: test memoryleak
        return sut
    }
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    )
    -> InfoProductViewModel {
        
        let model: Model = .mockWithEmptyExcept()
        let product = anyProduct(id: 0, productType: .card)
        
        let sut: InfoProductViewModel = .init(
            product: product,
            title: .title,
            list: .items,
            listWithAction: .items,
            additionalList: .cardItems,
            shareButton: .shareButton,
            model: model)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func makeSUT1(
        product: ProductData,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: InfoProductViewModel,
        model: Model
    ) {
        
        let model = Model.mockWithEmptyExcept()
        
        model.currencyList.value = .init(arrayLiteral: .rub)
        
        let sut = InfoProductViewModel(
            model: model,
            product: product
        )
        
        //TODO: trackMemoryLeak for model
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    func arrayOfIds(items:[ItemViewModelForList]) -> [DocumentItemModel.ID]{
        
        return Array(items.map{
            
            $0.currentValues.map {
                
                $0.id
            }
        }).flatMap{ $0 }
    }
}

private extension InfoProductViewModel.DocumentItemModel {
    
    static let info = ProductDetailsData.productDetailsDataFull
    
    static let payeeName: Self = .init(
        id: .payeeName,
        subtitle: info.payeeName,
        valueForCopy: "valueForCopy"
    )
    static let accountNumber: Self = .init(
        id: .accountNumber,
        subtitle: info.accountNumber,
        valueForCopy: "valueForCopy"
    )
    static let bic: Self = .init(
        id: .bic,
        subtitle: info.bic,
        valueForCopy: "valueForCopy"
    )
    static let corrAccount: Self = .init(
        id: .corrAccount,
        subtitle: info.corrAccount,
        valueForCopy: "valueForCopy"
    )
    static let inn: Self = .init(
        id: .inn,
        subtitle: info.inn,
        valueForCopy: "valueForCopy"
    )
    static let kpp: Self = .init(
        id: .kpp,
        subtitle: info.kpp,
        valueForCopy: "valueForCopy"
    )
    
    static let cardInfo = InfoProductViewModelTests.productCardDataFull
    
    static let holder: Self = .init(
        id: .holderName,
        subtitle: cardInfo.holderName!,
        valueForCopy: "valueForCopy"
    )
    static let number: Self = .init(
        id: .number,
        subtitle: cardInfo.number!,
        valueForCopy: "valueForCopy"
    )
    static let numberMask: Self = .init(
        id: .numberMasked,
        subtitle: cardInfo.numberMasked!,
        valueForCopy: "valueForCopy"
    )
    static let expirationDate: Self = .init(
        id: .expirationDate,
        subtitle: cardInfo.expireDate!,
        valueForCopy: "valueForCopy"
    )
    static let cvvMasked: Self = .init(
        id: .cvvMasked,
        subtitle: "***",
        valueForCopy: ""
    )
    static let cvv: Self = .init(
        id: .cvv,
        subtitle: "123",
        valueForCopy: "valueForCopy"
    )
}

private extension InfoProductViewModel.ButtonViewModel {
    
    static let shareButton: Self = .init(action: {})
}

private extension ProductDetailsData {
    
    static let productDetailsData: Self = .init(
        accountNumber: "4081781000000000001",
        bic: "044525341",
        corrAccount: "30101810300000000341",
        inn: "7704113772",
        kpp: "770401001",
        payeeName: "Иванов Иван Иванович",
        maskCardNumber: nil,
        cardNumber: nil)
    
    static let productDetailsDataFull: Self = .init(
        accountNumber: productDetailsData.accountNumber,
        bic: productDetailsData.bic,
        corrAccount: productDetailsData.corrAccount,
        inn: productDetailsData.inn,
        kpp: productDetailsData.kpp,
        payeeName: productDetailsData.payeeName,
        maskCardNumber: "4444 55** **** 1122",
        cardNumber: "4444 5555 6666 1122")
}

private extension InfoProductViewModelTests {
    
    static let productCardDataFull = ProductCardData(
        id: 10,
        productType: .card,
        number: "1111",
        numberMasked: "****",
        accountNumber: nil,
        balance: nil,
        balanceRub: nil,
        currency: "RUB",
        mainField: "Card",
        additionalField: nil,
        customName: nil,
        productName: "Card",
        openDate: nil,
        ownerId: 0,
        branchId: 0,
        allowCredit: true,
        allowDebit: true,
        extraLargeDesign: .init(description: ""),
        largeDesign: .init(description: ""),
        mediumDesign: .init(description: ""),
        smallDesign: .init(description: ""),
        fontDesignColor: .init(description: ""),
        background: [],
        accountId: nil,
        cardId: 0,
        name: "CARD",
        validThru: Date(),
        status: .active,
        expireDate: "01/01/01",
        holderName: "Иванов",
        product: nil,
        branch: "",
        miniStatement: nil,
        paymentSystemName: nil,
        paymentSystemImage: nil,
        loanBaseParam: nil,
        statusPc: nil,
        isMain: nil,
        externalId: nil,
        order: 0,
        visibility: true,
        smallDesignMd5hash: "",
        smallBackgroundDesignHash: "")
    
    static let productCardData = ProductCardData(
        id: 10,
        productType: .card,
        number: nil,
        numberMasked: nil,
        accountNumber: nil,
        balance: nil,
        balanceRub: nil,
        currency: "RUB",
        mainField: "Card",
        additionalField: nil,
        customName: nil,
        productName: "Card",
        openDate: nil,
        ownerId: 0,
        branchId: 0,
        allowCredit: true,
        allowDebit: true,
        extraLargeDesign: .init(description: ""),
        largeDesign: .init(description: ""),
        mediumDesign: .init(description: ""),
        smallDesign: .init(description: ""),
        fontDesignColor: .init(description: ""),
        background: [],
        accountId: nil,
        cardId: 0,
        name: "CARD",
        validThru: Date(),
        status: .active,
        expireDate: nil,
        holderName: nil,
        product: nil,
        branch: "",
        miniStatement: nil,
        paymentSystemName: nil,
        paymentSystemImage: nil,
        loanBaseParam: nil,
        statusPc: nil,
        isMain: nil,
        externalId: nil,
        order: 0,
        visibility: true,
        smallDesignMd5hash: "",
        smallBackgroundDesignHash: "")
}

private extension String {
    
    static let title = "Реквизиты счета и карты"
    static let stringForMultiple = "title: valueForCopy\ntitle1: valueForCopy"
    static let stringForSingle = "title: valueForCopy"
    static let stringForShare = """
item1 : subtitle1\nitem2 : subtitle2\nitem3 : subtitle3\n\n\n\nДержатель: valueForCopy\nНомер карты: valueForCopy\nКарта действует до: valueForCopy
"""
}

extension Array where Element == InfoProductViewModel.ItemViewModel {
    
    static let items: Self = [
        .init(title: "item1", subtitle: "subtitle1"),
        .init(title: "item2", subtitle: "subtitle2"),
        .init(title: "item3", subtitle: "subtitle3")
    ]
}

extension Array where Element == InfoProductViewModel.DocumentItemModel {
    
    static let documentItemsSingle: Self = [
        .accountNumber,
        .bic,
        .corrAccount,
        .payeeName
    ]
    
    static let documentItemsMultiple: Self = [
        .inn,
        .kpp
    ]
    
    static let cardItemsSingle: Self = [
        .holder,
        .number
    ]
    
    static let cardItemsMultiple: Self = [
        .expirationDate,
        .cvv
    ]
}

extension Array where Element == InfoProductViewModel.ItemViewModelWithAction {
    
    static let itemsForMultiple: Self = [
        .init(
            id: .kpp,
            title: "title",
            titleForInformer: "titleForInformer",
            subtitle: "subtitle",
            valueForCopy: "valueForCopy",
            actionForLongPress: { _,_ in },
            actionForIcon: {}
        ),
        .init(
            id: .inn,
            title: "title1",
            titleForInformer: "titleForInformer1",
            subtitle: "subtitle1",
            valueForCopy: "valueForCopy",
            actionForLongPress: { _,_ in },
            actionForIcon: {}
        )
    ]
}

private extension DepositInfoDataItem {
    
    static let data: Self = .init(
        id: 10000184511,
        initialAmount: 1000,
        termDay: "540",
        interestRate: 10000184511,
        sumPayInt: 1000,
        sumCredit: 1000,
        sumDebit: 1000,
        sumAccInt: 1000,
        balance: 1000,
        sumPayPrc: 1000,
        dateOpen: Date.dateUTC(with: 1648512000000),
        dateEnd: Date.dateUTC(with: 1648512000000),
        dateNext: Date.dateUTC(with: 1648512000000)
    )
    
    static let dataOtherId: Self = .init(
        id: 1,
        initialAmount: 1000,
        termDay: "540",
        interestRate: 10000184511,
        sumPayInt: 1000,
        sumCredit: 1000,
        sumDebit: 1000,
        sumAccInt: 1000,
        balance: 1000,
        sumPayPrc: 1000,
        dateOpen: Date.dateUTC(with: 1648512000000),
        dateEnd: Date.dateUTC(with: 1648512000000),
        dateNext: Date.dateUTC(with: 1648512000000)
    )
}

private extension ProductData {
    
    static func firstValue() -> ProductData {
        
        return .init(
            id: 10000184511,
            productType: .deposit,
            number: "1",
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "",
            additionalField: nil,
            customName: nil,
            productName: "name",
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

private extension ProductDetailsData {
    
    static let data: Self = .init(
        accountNumber: "accountNumber",
        bic: "bic",
        corrAccount: "corrAccount",
        inn: "inn",
        kpp: "kpp",
        payeeName: "payeeName",
        maskCardNumber: "maskCardNumber",
        cardNumber: "cardNumber"
    )
}

extension Array where Element == String {
    
    static let depositeTitles = [
        "Сумма первоначального размещения",
        "Дата открытия",
        "Дата закрытия",
        "Срок вклада",
        "Ставка по вкладу",
        "Дата следующего начисления процентов",
        "Сумма выплаченных процентов всего",
        "Суммы пополнений",
        "Суммы списаний",
        "Сумма начисленных процентов на дату"
    ]
    
    static let cardInfo = [
        "Получатель: payeeName",
        "Номер счета: accountNumber",
        "БИК: bic",
        "Корреспондентский счет: corrAccount",
        "ИНН: inn\nКПП: kpp"
    ]
}

private extension Date {
    
    static let testDateInMoscowTimezone = Date(timeIntervalSince1970: 1679272800) // 2023-03-20 00:00:00 +0300
    static let expectedMoscowTime = Date(timeIntervalSince1970: 1679272800) // 2023-03-20 00:00:00 +0300
    static let testDateInDifferentTimezone = Date(timeIntervalSince1970: 1679286300) // 2023-03-20 03:00:00 +0500
    static let expectedDifferentTimezoneResult = Date(timeIntervalSince1970: 1679272800) // 2023-03-20 00:00:00 +0300
}
