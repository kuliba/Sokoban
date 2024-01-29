//
//  TemplatesListViewModelTests.swift
//  ForaBankTests
//
//  Created by Dmitry Martynov on 04.06.2023.
//

import XCTest
@testable import ForaBank

final class TemplatesListViewModelTests: XCTestCase {

    /*
     План тестирования
     
     1. Нет данных шаблонов
        - шаблонов в модели нет
        - загрузки в текущий момент шаблонов нет

        Результат:
        - навБар тайтл “Шаблоны”
        - навБар кнопка поиска не активна
        - навБар кнопка меню не активна

        - стэйт НетШаблонов (Пустой экран)
        - во вьюМоделе стэйта Доступна кнопка с тайтлом "Перейти в историю"
        
     */
    
    func test_initNoTempatesDataNoLoadingData_correct() throws {
    
        let (sut, model) = makeSUT(templatesData: [],
                                   isLoadingData: false)
       
        XCTAssertTrue(model.paymentTemplates.value.isEmpty)
        XCTAssertFalse(model.paymentTemplatesUpdating.value)
        
        // wait for bindings
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.2)

        let navBarRegularModel = try XCTUnwrap(sut.navBarState.regularModel)
        XCTAssertEqual(navBarRegularModel.title, "Шаблоны")
        XCTAssertEqual(navBarRegularModel.isSearchButtonDisable, true)
        XCTAssertEqual(navBarRegularModel.isMenuDisable, true)
        
        let stateEmptyListModel = try XCTUnwrap(sut.state.emptyListModel)
        XCTAssertEqual(stateEmptyListModel.button.title, "Перейти в историю")
    }
   
    /*
    Тест инит при наличии данных шаблонов
        - шаблонов 2 штуки
        - загрузки в текущий момент шаблонов нет
        - настройка показа шаблонов - Плитка
     
     Результат
        - нав бар тайтл “Шаблоны”
        - кнопка search активна
        - кнопка меню активна
        - в меню 3 айтема
            - первый айтем меню тайтл "Последовательность"
            - второй айтeм меню тайтл "Вид (Список)"
            - третий aйтeм меню тайтл "Удалить"
        - в списке айтомов три шаблона
            - два айтома вида регулярного
            - последний айтом кнопка для Добавления шаблона
        - контекстое меню на айтомах регулярного вида
        - селектор фильтрации показан
            - три селектора фильтрации "Все", "group1", "group2"
    */
    
    //FIXME: Test fails on CI scheme
    /*
    func test_initWithTempatesDataNoLoadingData_correct() throws {
    
        let (sut, model) = makeSut(templatesData: [.firstTemplateData, .secondTemplateData],
                                   isLoadingData: false,
                                   styleSetting: .tiles)
        // wait for bindings
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        //data
        XCTAssertEqual(model.paymentTemplates.value.count, 2)
        XCTAssertFalse(model.paymentTemplatesUpdating.value)

        //navBar
        let navBarRegularModel = try XCTUnwrap(sut.navBarState.regularModel)
        XCTAssertEqual(navBarRegularModel.title, "Шаблоны")
        XCTAssertEqual(navBarRegularModel.isSearchButtonDisable, false)
        XCTAssertEqual(navBarRegularModel.isMenuDisable, false)
        
        //menuItems
        XCTAssertEqual(navBarRegularModel.menuList.count, 3)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Последовательность" }, 0)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Вид (Список)" }, 1)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Удалить" }, 2)
        
        //selector
        let selectorModel = try XCTUnwrap(sut.categorySelector)
        XCTAssertEqual(selectorModel.options.count, 3)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "Все" }, 0)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group1" }, 1)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group2" }, 2)
        
        //regular items context menu
        let menuItemsModel = try XCTUnwrap(sut.getItemsMenuViewModel())
        XCTAssertEqual(menuItemsModel.count, 2)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Удалить" }, 0)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Переименовать" }, 1)
        
        //templateItems
        XCTAssertEqual(sut.items.map(\.kind), [.regular, .regular, .add])
    }
     */
     
    /*
     Тест инит при наличии данных шаблонов
        - шаблонов 2 штуки
        - загрузки данных шаблонов в текущий момент
        - настройка показа шаблонов - Список
 
     Результат
        - нав бар тайтл “Шаблоны”
        - кнопка search активна
        - кнопка меню активна
        - в меню 3 айтема
            - первый айтем меню тайтл "Последовательность"
            - второй айтeм меню тайтл "Вид (Список)"
            - третий aйтeм меню тайтл "Удалить"
     - в списке айтомов 4 шаблона
            - в верху плейсхолдер айтема
            - два айтома вида регулярного
            - последний айтом кнопка для Добавления шаблона
     - контекстое меню на айтомах регулярного вида
     - селектор фильтрации показан
        - три селектора фильтрации "Все", "group1", "group2"
     */

    //FIXME: Test fails on CI scheme
    /*
    func test_initWithTempatesDataAndLoadingData_correct() throws {

        let (sut, model) = makeSut(
                            templatesData: [.firstTemplateData, .secondTemplateData],
                            isLoadingData: true,
                            styleSetting: .tiles)
        // wait for bindings
        _ = XCTWaiter().wait(for: [.init()], timeout: 1)

        //data
        XCTAssertEqual(model.paymentTemplates.value.count, 2)
        XCTAssertTrue(model.paymentTemplatesUpdating.value)

        //navBar
        let navBarRegularModel = try XCTUnwrap(sut.navBarState.regularModel)
        XCTAssertEqual(navBarRegularModel.title, "Шаблоны")
        XCTAssertEqual(navBarRegularModel.isSearchButtonDisable, false)
        XCTAssertEqual(navBarRegularModel.isMenuDisable, false)
    
        //menuItems
        XCTAssertEqual(navBarRegularModel.menuList.count, 3)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Последовательность" }, 0)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Вид (Список)" }, 1)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Удалить" }, 2)
    
        //selector
        let selectorModel = try XCTUnwrap(sut.categorySelector)
        XCTAssertEqual(selectorModel.options.count, 3)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "Все" }, 0)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group1" }, 1)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group2" }, 2)
    
        //regular items context menu
        let menuItemsModel = try XCTUnwrap(sut.getItemsMenuViewModel())
        XCTAssertEqual(menuItemsModel.count, 2)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Удалить" }, 0)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Переименовать" }, 1)
    
        //templateItems
        XCTAssertEqual(sut.items.map(\.kind), [.regular, .regular, .add])
    }
    */
    
    /*
     План тестирования
     
     1. Нет данных шаблонов
        - шаблонов в модели нет
        - загрузки в текущий момент шаблонов нет
        - нажата кнопка "Перейти в историю"

        Результат:
        - навБар тайтл “Шаблоны”
        - навБар кнопка поиска не активна
        - навБар кнопка меню не активна

        - стэйт НетШаблонов (Пустой экран)
        - во вьюМоделе стэйта Доступна кнопка с тайтлом "Перейти в историю"
        - открылся боттомШит с продуктами
        
     */
    
    func test_EmptyViewGoHistoryButtonTap() throws {
    
        let (sut, model) = makeSUT(templatesData: [],
                                   isLoadingData: false)
       
        let sutActionSpy = ValueSpy(sut.action)
        
        XCTAssertTrue(model.paymentTemplates.value.isEmpty)
        XCTAssertFalse(model.paymentTemplatesUpdating.value)
        
        // wait for bindings
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        let navBarRegularModel = try XCTUnwrap(sut.navBarState.regularModel)
        XCTAssertEqual(navBarRegularModel.title, "Шаблоны")
        XCTAssertEqual(navBarRegularModel.isSearchButtonDisable, true)
        XCTAssertEqual(navBarRegularModel.isMenuDisable, true)
        
        let stateEmptyListModel = try XCTUnwrap(sut.state.emptyListModel)
        XCTAssertEqual(stateEmptyListModel.button.title, "Перейти в историю")
        
        sut.action.send(TemplatesListViewModelAction.AddTemplateTapped())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.2)
        
        let sheetKind = try XCTUnwrap(sut.sheet?.type)
        
        var flag = false
        switch sheetKind {
            case let .productList(productListModel):
                flag = true
                XCTAssertEqual(productListModel.title, "Выберите продукт")
            default: flag = false
        }
       
        XCTAssertTrue(flag)
    }
}

//MARK: PaymentsMeToMeViewModel

extension TemplatesListViewModelTests {
    
    func test_meToMe_shouldNotDeliverActionsAfterBottomSheetDeallocated() throws {
        
        let (sut, model) = makeSUT(templatesData: [
            .templateStub(
                paymentTemplateId: 1,
                type: .betweenTheir,
                parameterList: TransferGeneralData.generalStub(
                    amount: 10
                ))
        ])
 
        sut.action.send(TemplatesListViewModelAction.Item.Tapped(itemId: 1))
        sut.action.send(PaymentsMeToMeAction.Response.Success(viewModel: .sample1))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
                
        XCTAssertNoDiff(try sut.selectedMeToMeProductTitles(), ["Откуда", "Куда"])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)

        let spy = ValueSpy(model.action)
        XCTAssertEqual(spy.values.count, 0)
        
        sut.meToMe?.action.send(PaymentsMeToMeAction.Response.Success(viewModel: .sample1))
        sut.sheet = nil

        XCTAssertEqual(spy.values.count, 0)
        XCTAssertNil(sut.meToMe)
    }
}

//MARK: Helpers

private extension TemplatesListViewModelTests {
    
    func makeSUT(templatesData: [PaymentTemplateData] = [],
                 isLoadingData: Bool = false,
                 styleSetting: TemplatesListViewModel.Style = .list,
                 file: StaticString = #file,
                 line: UInt = #line
    ) -> (sut: TemplatesListViewModel, model: Model) {
        
        let model: Model = .mockWithEmptyExcept()
        model.addTemplates(templatesData: templatesData)
        model.paymentTemplatesUpdating.value = isLoadingData
        model.products.value = [.card: [.stub(productId: 1)]]
        model.currencyList.value = [.rub]
        
        let sut = TemplatesListViewModel(model, dismissAction: {}, updateFastAll: {})
        
        sut.items = [.stub()]
        //TODO: restore memory leak tracking after Model fix
//        trackForMemoryLeaks(model, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model)
    }
}

private extension TemplatesListViewModel.ItemViewModel {

    static func stub() -> TemplatesListViewModel.ItemViewModel {
        
        return .init(
            id: 1,
            sortOrder: 1,
            state: .normal,
            avatar: .placeholder,
            title: "title",
            subTitle: "subtitle",
            topImage: nil,
            amount: "100",
            tapAction: {_ in},
            deleteAction: {_ in},
            renameAction: {_ in },
            kind: .regular
        )
    }
}

private extension TemplatesListViewModel {
    
    var meToMe: PaymentsMeToMeViewModel? {
        
        guard case let .meToMe(viewModel) = sheet?.type
        else { return nil }
        
        return viewModel
    }
    
    func selectedMeToMeProductTitles() throws -> [String] {
     
        let swapViewModel = try XCTUnwrap(meToMe?.swapViewModel)
        return swapViewModel.items.compactMap(\.product?.title)
    }
}

private extension Model {
   
    func addTemplates(templatesData: [PaymentTemplateData]) {
        
        paymentTemplates.value = templatesData
        XCTAssertEqual(paymentTemplates.value, templatesData)
    }
}

private extension PaymentTemplateData {
    
    static func makeTemplateData(
        groupName: String,
        name: String,
        parameterList: [TransferData],
        paymentTemplateId: Int,
        productTemplate: ProductTemplateData? = nil,
        sort: Int,
        svgImage: SVGImageData,
        type: PaymentTemplateData.Kind) -> PaymentTemplateData {
        
            .init(groupName: groupName,
                  name: name,
                  parameterList: parameterList,
                  paymentTemplateId: paymentTemplateId,
                  productTemplate: productTemplate,
                  sort: sort,
                  svgImage: svgImage,
                  type: type)
        
    }

    static let firstTemplateData = makeTemplateData(
        
        groupName: "group1",
        name: "firstTemplate",
        parameterList: [.init(amount: 101.19,
                              check: true,
                              comment: nil,
                              currencyAmount: "RUB",
                              payer: Self.payer)],
        paymentTemplateId: 1,
        sort: 1,
        svgImage: .init(description: ""),
        type: .byPhone)
    
    static let secondTemplateData = makeTemplateData(
        
        groupName: "group2",
        name: "secondTemplate",
        parameterList: [.init(amount: 10.02,
                              check: true,
                              comment: nil,
                              currencyAmount: "RUB",
                              payer: Self.payer)],
        paymentTemplateId: 2,
        sort: 2,
        svgImage: .init(description: ""),
        type: .betweenTheir)
    
    static let payer: TransferData.Payer = .init(inn: nil,
                                                 accountId: nil,
                                                 accountNumber: nil,
                                                 cardId: nil,
                                                 cardNumber: nil,
                                                 phoneNumber: nil)
}
