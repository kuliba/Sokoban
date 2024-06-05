//
//  CardViewComponentTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 03.05.2023.
//

@testable import ForaBank
import XCTest
@testable import CardUI

final class CardViewComponentTests: XCTestCase {
    
    func test_init_shouldSetInitialValues() {
        
        let sut = makeSUT(id: 1,
                          productType: .card,
                          header: .init(number: "78"),
                          name: "Visa",
                          footer: .init(balance: "170 ₽"),
                          appearance: .init(
                            background: .init(
                                color: .green,
                                image: .ic40Card),
                            colors: .init(text: .red, checkBackground: .gray)
                          ))
        
        XCTAssertEqual(sut.id, 1)
        XCTAssertEqual(sut.isChecked, false)
        XCTAssertEqual(sut.isUpdating, false)
        XCTAssertEqual(sut.cardInfo, .defaultValueEmptyOwner)
        
        XCTAssertEqual(sut.productType, .card)
        
        XCTAssertEqual(sut.header.number, "78")
        XCTAssertEqual(sut.footer.balance, "170 ₽")
        
        XCTAssertEqual(sut.appearance.background.color, .green)
        XCTAssertEqual(sut.appearance.background.image, .ic40Card)
        
        XCTAssertEqual(sut.appearance.colors.text, .red)
        XCTAssertEqual(sut.appearance.colors.checkBackground, .gray)
    }
    
    func test_convenience_init_account_shouldSetInitialValues() {
        
        let product = ProductData(productType: .account)
        
        let sut = makeSUT(productData: product, size: .normal, style: .profile)
        
        XCTAssertEqual(sut.id, 1)
        XCTAssertEqual(sut.isChecked, false)
        XCTAssertEqual(sut.isUpdating, false)
        XCTAssertEqual(sut.cardInfo, .defaultValueEmpty)
        XCTAssertEqual(sut.productType, .account)
        XCTAssertEqual(sut.appearance.size, .normal)
        XCTAssertEqual(sut.appearance.style, .profile)
    }
    
    func test_convenience_init_card_shouldSetInitialValues() {
        
        let product = ProductCardData(holderName: "Петров")
        
        let sut = makeSUT(productData: product, size: .normal, style: .profile)
        
        XCTAssertEqual(sut.id, 1)
        XCTAssertEqual(sut.isChecked, false)
        XCTAssertEqual(sut.isUpdating, false)
        XCTAssertEqual(sut.cardInfo, .defaultValue)
        
        XCTAssertEqual(sut.productType, .card)
        XCTAssertEqual(sut.appearance.size, .normal)
        XCTAssertEqual(sut.appearance.style, .profile)
    }
    
    // MARK: - Test name, as ProductCardData
    
    func testNameReturnsEmptyForEmptyProduct() {
        
        let product = ProductData(productType: .card)
        
        let str = ProductViewModel.name(product: product, style: .main, creditProductName: .cardTitle)
        
        XCTAssertEqual(str, "")
    }
    func testNameReturnsDisplayNameForMainStyle() {
        
        let productData = ProductData(productType: .card)
        
        let name = ProductViewModel.name(product: productData, style: .main, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "")
    }
    
    func testNameReturnsMainFieldNameForMainStyle() {
        
        let product = ProductCardData()
        let name = ProductViewModel.name(product: product, style: .main, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "Visa")
    }
    
    func testNameReturnsCustomNameForProfileStyle() {
        
        let product = ProductCardData.product
        product.update(with: .init(balance: 100, balanceRub: 200, customName: "Кредитная полка"))
        let name = ProductViewModel.name(product: product, style: .profile, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "Кредитная полка")
    }
    
    func testNameReturnsEmptyForEmptyCustomName() {
        
        let product = ProductCardData.product
        product.update(with: .init(balance: 100, balanceRub: 200, customName: ""))
        let name = ProductViewModel.name(product: product, style: .profile, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "")
    }
    
    func testNameReturnsEmptyForEmptyFields() {
        
        let product = ProductCardData.productWithCustomFields(mainField: "", customName: "")
        let name = ProductViewModel.name(product: product, style: .profile, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "")
        
    }
    
    func testNameUsesMainFieldWhenCustomNameIsNil() {
        
        let product = ProductCardData.productWithCustomFields(mainField: "Visa Gold", customName: nil)
        let name = ProductViewModel.name(product: product, style: .profile, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "Visa Gold")
        
    }
    
    func testNameUsesCustomNameOverMainField() {
        
        let product = ProductCardData.productWithCustomFields(mainField: "mainField", customName: "customName")
        let name = ProductViewModel.name(product: product, style: .main, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "customName")
    }
    
    func testNameAddsCreditForProfileAndCreditCard() {
        
        let product = ProductCardData.productWithLoan
        let name = ProductViewModel.name(product: product, style: .profile, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "Кредитная\nVisa")
    }
    
    func testNameReturnsDefaultCreditCardForEmptyFieldsAndMainStyle() {
        
        let product = ProductCardData.productWithCustomFields(mainField: "", customName: "")
        let name = ProductViewModel.name(product: product, style: .main, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "Кредитная карта")
    }
    
    func testNameReturnsDefaultCreditCardForNilCustomNameAndMainStyle() {
        
        let product = ProductCardData.productWithCustomFields(mainField: "", customName: nil)
        let name = ProductViewModel.name(product: product, style: .main, creditProductName: .cardTitle)
        
        XCTAssertEqual(name, "Кредитная карта")
    }
    
    // MARK: - Test owner
    
    func test_owner_shouldEmptyIfDeposit() {
        
        let product = ProductData(productType: .deposit)
        
        let str = ProductViewModel.owner(from: product)
        
        XCTAssertEqual(str, "")
    }
    
    func test_owner_shouldEmptyIfAccount() {
        
        let product = ProductData(productType: .account)
        
        let str = ProductViewModel.owner(from: product)
        
        XCTAssertEqual(str, "")
    }
    
    func test_owner_shouldEmptyIfCardAndHolderEmpty() {
        
        let product = ProductCardData(holderName: nil)
        
        let str = ProductViewModel.owner(from: product)
        
        XCTAssertEqual(str, "")
    }
    
    func test_owner_shouldSetOwnerIfCardAndHolderNotEmpty() {
        
        let product = ProductCardData(holderName: "Петров")
        
        let str = ProductViewModel.owner(from: product)
        
        XCTAssertEqual(str, "Петров")
    }
    
    // MARK: - Test Rate Formatted
    
    func test_rateFormattedForDeposit_isNotNull() {
        
        let product = ProductDepositData(interestRate: 10.45)
        
        let str = ProductViewModel.rateFormatted(product: product)
        
        XCTAssertEqual(str, "10.45%")
    }
    
    func test_rateFormattedForAccount_isNull() {
        
        let product = ProductData(productType: .account)
        
        let str = ProductViewModel.rateFormatted(product: product)
        
        XCTAssertNil(str)
    }
    
    func test_rateFormattedForCard_isNull() {
        
        let product = ProductData(productType: .card)
        
        let str = ProductViewModel.rateFormatted(product: product)
        
        XCTAssertNil(str)
    }
    
    //MARK: - Test maskedValue
    
    func test_maskedValue_valueNil_shouldEpty() {
        
        let value: String? = nil
        
        let str = ProductViewModel.maskedValue(
            value,
            replacements: .replacements
        )
        
        XCTAssertNoDiff(str, "")
    }
    
    func test_maskedValue_valueNotNil_shouldMaskedNumber() {
        
        let value = "4444-XXXX-XXXX-1122"
        
        let str = ProductViewModel.maskedValue(
            value,
            replacements: .replacements
        )
        
        XCTAssertNoDiff(str, "4444 **** **** 1122")
    }
    
    // MARK: - Test ShowingCardFront
    
    func test_showingCardFrontInitialValue_isFalse() {
        
        let sut = makeSUT(size: .large)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
    }
    
    func test_showingCardFront_shouldToggle_onProductDidTapped_onLargeCard() {
        
        let sut = makeSUT(productType: .card, size: .large)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, true)
    }
    
    func test_showingCardFront_shouldNotToggle_onProductDidTapped_onSmallCard() {
        
        let sut = makeSUT(productType: .card, size: .small)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
    }
    
    func test_showingCardFront_shouldNotToggle_onProductDidTapped_onSmallAccount() {
        
        let sut = makeSUT(productType: .account, size: .small)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
    }
    
    func test_showingCardFront_shouldNotToggle_onProductDidTapped_onLargeAccount() {
        
        let sut = makeSUT(productType: .account, size: .large)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
    }
    
    func test_showingCardFront_shouldNotToggle_onProductDidTapped_onSmallDeposit() {
        
        let sut = makeSUT(productType: .deposit, size: .small)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
    }
    
    func test_showingCardFront_shouldNotToggle_onProductDidTapped_onLargeDeposit() {
        
        let sut = makeSUT(productType: .deposit, size: .large)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
    }
    
    // MARK: - Test animationAtFisrtShowCard
    
    func test_animationAtFisrtShowCard_shouldToggle_onLargeCard() {
        
        let sut = makeSUT(
            productData: .init(productType: .card),
            size: .large,
            style: .profile
        )
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        sut.animationAtFisrtShowCard()
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, true)
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
    }
    
    func test_animationAtFisrtShowCard_shouldNotToggle_onSmallCard() {
        
        let sut = makeSUT(size: .small)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        sut.animationAtFisrtShowCard()
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
    }
    
    func test_animationAtFisrtShowCard_shouldNotToggle_onLargeDeposint() {
        
        let sut = makeSUT(productType: .deposit, size: .large)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        sut.animationAtFisrtShowCard()
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
    }
    
    func test_animationAtFisrtShowCard_shouldNotToggle_onSmallDeposint() {
        
        let sut = makeSUT(productType: .deposit, size: .small)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        sut.animationAtFisrtShowCard()
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
    }
    
    func test_animationAtFisrtShowCard_shouldNotToggle_onLargeAccount() {
        
        let sut = makeSUT(productType: .account, size: .large)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        sut.animationAtFisrtShowCard()
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
    }
    
    func test_animationAtFisrtShowCard_shouldNotToggle_onSmallAccount() {
        
        let sut = makeSUT(productType: .account, size: .small)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        sut.animationAtFisrtShowCard()
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 1)
        
        XCTAssertEqual(sut.cardInfo.cardWiggle, false)
    }
    
    // MARK: - Test Show CVV
    
    func test_showCVV() {
        
        var startValue = 1
        
        let sut = makeSUT(
            showCVV: { _,_  in
                startValue = 2
            },
            size: .large
        )
        XCTAssertEqual(sut.cardInfo.state, .showFront)
        
        sut.showCVVButtonTap()
        
        XCTAssertEqual(startValue, 2)
    }
    
    // MARK: - Test Copy To Clipboard
    
    func test_copyToClipboardCVVClose() {
        
        let sut = makeSUT(productType: .card, size: .large)
        XCTAssertEqual(sut.cardInfo.state, .showFront)
        
        // copy number to clipboard
        sut.copyCardNumberToClipboard()
        
        XCTAssertEqual(sut.cardInfo.state, .fullNumberMaskedCVV)
        XCTAssertEqual(sut.cardInfo.fullNumber.value, UIPasteboard.general.string)
        XCTAssertEqual(sut.cardInfo.numberToDisplay, FullNumber.number.value.formatted())
    }
    
    func test_copyToClipboardCVVOpen() {
        
        let sut = makeSUT(productType: .card, size: .large)
        
        XCTAssertEqual(sut.cardInfo.state, .showFront)
        XCTAssertEqual(sut.cardInfo.cvvToDisplay, .cvvTitle)
        
        // open CVV
        sut.showCVVButtonTap()
        
        // copy number to clipboard
        sut.copyCardNumberToClipboard()
        
        XCTAssertEqual(sut.cardInfo.state, .fullNumberMaskedCVV)
        XCTAssertEqual(sut.cardInfo.fullNumber.value, UIPasteboard.general.string)
    }
    
    // MARK: - Test Showing Full Number - full path
    
    func test_showingFullNumber_fullPathWithCopyNumberToClipboardWithOutShowCVVAndFlipCard_onLargeCard() {
        
        let sut = makeSUT(productType: .card, size: .large)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        XCTAssertEqual(sut.cardInfo.state, .showFront)
        
        // flipped the card
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, true)
        XCTAssertEqual(sut.cardInfo.state, .fullNumberMaskedCVV)
        
        // copy number to clipboard
        sut.copyCardNumberToClipboard()
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, true)
        XCTAssertEqual(sut.cardInfo.state, .fullNumberMaskedCVV)
        
        // flipped the card back
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        XCTAssertEqual(sut.cardInfo.state, .showFront)
    }
    
    func test_showingFullNumber_fullPathWithOutCopyNumberToClipboardWithOutShowCVVAndFlipCard_onLargeCard() {
        
        let sut = makeSUT(productType: .card, size: .large)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        XCTAssertEqual(sut.cardInfo.state, .showFront)
        
        // flipped the card
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, true)
        XCTAssertEqual(sut.cardInfo.state, .fullNumberMaskedCVV)
        
        // flipped the card back
        sut.productDidTapped()
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.cardInfo.isShowingCardBack, false)
        XCTAssertEqual(sut.cardInfo.state, .showFront)
    }
    
    // MARK: - Helpers
    
    typealias FullNumber = CardInfo.FullNumber
    typealias MaskedNumber = CardInfo.MaskedNumber
    
    private func makeSUT(
        id: ProductData.ID,
        productType: ProductType,
        header: HeaderDetails,
        name: String,
        footer:FooterDetails,
        appearance: Appearance,
        cardAction: ProductViewModel.CardAction? = { _ in },
        showCVV: ShowCVV? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductViewModel {
        
        let sut =  ProductViewModel(
            id: id,
            header: header,
            cardInfo: .init(
                name: name,
                owner: "",
                cvvTitle: .cvvTitle,
                cardWiggle: false,
                fullNumber: .number,
                numberMasked: .maskedNumber
            ),
            footer: footer,
            statusAction: .init(status: .unblock),
            appearance: appearance,
            isUpdating: false,
            productType: productType,
            cardAction: cardAction,
            cvvInfo: .init(showCvv: showCVV, cardType: nil, cardStatus: nil)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT(
        productType: ProductType = .card,
        cardStatus: ProductCardData.StatusCard? = .active,
        cardType: ProductCardData.CardType? = .main,
        cardAction: ProductViewModel.CardAction? = { _ in },
        showCVV: ShowCVV? = nil,
        size: Appearance.Size = .small,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductViewModel {
        
        let sut =  ProductViewModel(
            id: 1,
            header: .init(number: "7854"),
            cardInfo: .classicCard,
            footer: .init(balance: "170 897 ₽"),
            statusAction: .init(status: .unblock),
            appearance: .init(
                background: .init(color: .clear, image: nil),
                colors: .init(text: .clear, checkBackground: .gray),
                size: size),
            isUpdating: false,
            productType: productType,
            cardAction: cardAction,
            cvvInfo: .init(
                showCvv: showCVV,
                cardType: cardType,
                cardStatus: cardStatus
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeSUT(
        productData: ProductData,
        size: Appearance.Size,
        style: Appearance.Style,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductViewModel {
        
        let model: Model = .mockWithEmptyExcept()
        
        model.handleResetProfileOnboardingSettings()
        
        let sut =  ProductViewModel(
            with: productData,
            size: size,
            style: style,
            model: model
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension ProductDepositData {
    
    convenience init(
        interestRate: Double,
        allowCredit: Bool = true,
        allowDebit: Bool = true,
        status: ProductData.Status = .active)
    {
        
        self.init(
            id: 1,
            productType: .deposit,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "",
            additionalField: nil,
            customName: nil,
            productName: "",
            openDate: nil,
            ownerId: 0,
            branchId: nil,
            allowCredit: allowCredit,
            allowDebit: allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: ""),
            background: [],
            depositProductId: 0,
            depositId: 0,
            interestRate: interestRate,
            accountId: 0,
            creditMinimumAmount: 0,
            minimumBalance: 0,
            endDate: nil,
            endDateNf: true,
            isDemandDeposit: true,
            isDebitInterestAvailable: false,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "")
    }
}

private extension ProductData {
    
    convenience init(
        productType: ProductType,
        allowCredit: Bool = true,
        allowDebit: Bool = true,
        status: ProductData.Status = .active)
    {
        
        self.init(
            id: 1,
            productType: productType,
            number: nil,
            numberMasked: nil,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: "RUB",
            mainField: "",
            additionalField: nil,
            customName: nil,
            productName: "",
            openDate: nil,
            ownerId: 1,
            branchId: nil,
            allowCredit: allowCredit,
            allowDebit: allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: ""),
            background: [],
            order: 1,
            isVisible: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "")
    }
}

private extension ProductCardData {
    
    convenience init(
        id: Int = 1,
        currency: Currency = .init(description: "RUB"),
        number: String = "4444 4444 4444 4444",
        numberMasked: String = "4444 **** **** **44",
        ownerId: Int = 0,
        holderName: String? = "Иванов",
        allowCredit: Bool = true,
        allowDebit: Bool = true,
        status: ProductData.Status = .active,
        loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil,
        statusPc: ProductData.StatusPC = .active,
        isMain: Bool = true
    ) {
        
        self.init(
            id: id,
            productType: .card,
            number: number,
            numberMasked: numberMasked,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: currency.description,
            mainField: "Visa",
            additionalField: nil,
            customName: nil,
            productName: "",
            openDate: nil,
            ownerId: ownerId,
            branchId: nil,
            allowCredit: allowCredit,
            allowDebit: allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: ""),
            background: [],
            accountId: nil,
            cardId: 0,
            name: "",
            validThru: Date(),
            status: status,
            expireDate: nil,
            holderName: holderName,
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: loanBaseParam,
            statusPc: statusPc,
            isMain: isMain,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "")
    }
}

private extension CardInfo {
    
    static let defaultValueEmptyOwner: Self = .init(
        name: "Visa",
        owner: "",
        cvvTitle: .cvvTitle,
        cardWiggle: false,
        fullNumber: .number,
        numberMasked: .maskedNumber
    )
    
    static let defaultValueEmpty: Self = .init(
        name: "",
        owner: "",
        cvvTitle: .emptyTitle,
        cardWiggle: false,
        fullNumber: .emptyNumber,
        numberMasked: .emptyMaskedNumber
    )
    
    static let defaultValue: Self = .init(
        name: "Visa",
        owner: "Петров",
        cvvTitle: .cvvTitle,
        cardWiggle: false,
        fullNumber: .number,
        numberMasked: .maskedNumber
    )
}

private  extension CardViewComponentTests {
    
    static let productWithLoan = ProductCardData(
        holderName: "My Card",
        loanBaseParam: .init(loanId: 1, clientId: 1, number: "1", currencyId: 1, currencyNumber: 1, currencyCode: "1", minimumPayment: 1, gracePeriodPayment: 1, overduePayment: 1, availableExceedLimit: 1, ownFunds: 1, debtAmount: 1, totalAvailableAmount: 1, totalDebtAmount: 1))
}
private extension ColorData {
    
}
private extension ProductCardData {
    
    static let product = ProductCardData(id: 1, currency: .init(description: "qwe"), number: "1", numberMasked: "1", ownerId: 1, holderName: "1", allowCredit: true, allowDebit: true, status: .active, loanBaseParam: nil, statusPc: .active, isMain: true)
    
    static func productWithCustomFields(
        mainField: String = "Visa",
        customName: String? = nil
    ) -> ProductCardData {
        
        return ProductCardData(
            id: 1,
            productType: .card,
            number: "1234 5678 9012 3456",
            numberMasked: "**** **** **** 3456",
            accountNumber: "1234567890123456",
            balance: 1000.0,
            balanceRub: 75000.0,
            currency: "USD",
            mainField: mainField,
            additionalField: "Additional Info",
            customName: customName,
            productName: "Visa Gold", openDate: Date(), ownerId: 123, branchId: 456, allowCredit: true, allowDebit: true, extraLargeDesign: .test, largeDesign: .test, mediumDesign: .test, smallDesign: .test, fontDesignColor: .init(description: "qwe"), background: [.init(description: "asd")], accountId: 789, cardId: 987, name: "John Doe", validThru: Date(), status: .active, expireDate: "12/25", holderName: "Andrew", product: "Credit Card", branch: "Main Branch", miniStatement: nil, paymentSystemName: "psn", paymentSystemImage: .test, loanBaseParam: nil, statusPc: .active, isMain: true, externalId: 321, order: 1, visibility: true, smallDesignMd5hash: "md5hash", smallBackgroundDesignHash: "backgroundHash")
    }
    
    static let productWithLoan = ProductCardData(
        holderName: "My Card",
        loanBaseParam: .init(loanId: 1, clientId: 1, number: "1", currencyId: 1, currencyNumber: 1, currencyCode: "1", minimumPayment: 1, gracePeriodPayment: 1, overduePayment: 1, availableExceedLimit: 1, ownFunds: 1, debtAmount: 1, totalAvailableAmount: 1, totalDebtAmount: 1))
}
