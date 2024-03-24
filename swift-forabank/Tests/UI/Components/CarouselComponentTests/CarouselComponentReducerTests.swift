//
//  CarouselComponentReducerTests.swift
//
//
//  Created by Disman Dmitry on 23.01.2024.
//

@testable import CarouselComponent
import XCTest
import RxViewModel

final class CarouselComponentReducerTests: XCTestCase {
    
    // MARK: - Reducer events
    
    func test_toggle_shouldNotToggleGroupFromCollapsedForEmptyProducts() {
        
        assert(.update(.empty), on: .empty) {
            
            $0[.card]?.state = .collapsed
        }
    }
    
    func test_toggle_shouldToggleGroupToExpanded() {
        
        assert(.toggle(id: .card, screenwidth: 0, xOffset: 0), on: .cards) {
            
            $0[.card]?.state = .expanded
        }
    }
    
    func test_scrolledTo_shouldSelectProduct() {
        
        assert(.scrolledTo(.card), on: .cards) {
            
            $0.selectedProductType = .card
            $0.selector.selected = .card
        }
    }

    func test_select_shouldEmitEffect() {
        
        let dispatchAfterTimeInterval: TimeInterval = 0.2
        
        assert(.select(.card), on: .cards, effect: .scrollTo(.card, dispatchAfterTimeInterval))
    }
    
    func test_didScrollTo_shouldCallDidScrollToEffectOnSelectEvent() {
        
        assert(.select(.card), on: .cards) {
            
            $0.selector.selected = .card
        }
    }
    
    func test_update_shouldUpdateEmptyProducts() {
        
        assert(.empty, .update(.empty), reducedTo: .init(products: [], needShowSticker: true))
    }
    
    func test_update_shouldUpdateToMoreProductsFromEmptyProducts() {
        
        assert(.empty, .update(.moreProducts), reducedTo: .init(products: .moreProducts, needShowSticker: true))
    }
    
    func test_update_shouldUpdateToPreviewProductsFromEmptyProducts() {
        
        assert(.empty, .update(.cards), reducedTo: .init(products: .cards, needShowSticker: true))
    }
    
    func test_update_shouldUpdateToMoreProductsFromDefault() {
        
        assert(.cards, .update(.moreProducts), reducedTo: .init(products: .moreProducts, needShowSticker: true))
    }
    
    func test_update_shouldUpdateToPreviewProductsFromDefault() {
        
        assert(.cards, .update(.cards), reducedTo: .init(products: .cards, needShowSticker: true))
    }
    
    func test_closeSticker_shouldSetNeedShowStickerToFalse() {
        
        assert(.closeSticker, on: .all) {
            
           $0.needShowSticker = false
       }
    }
    
    // MARK: - Separators mapping
    
    func test_separators_shouldNotUpdateEmptyWithEmptyProducts() {
        
        assert(.update(.empty), on: .empty) { _ in }
    }
    
    func test_separators_shouldNotUpdateEmptySeparatorsWithNonCardProducts() {
        
        assert(.update(.nonCardProducts), on: .empty) {
           
            $0.selector = .init(items: [.account, .deposit, .loan])
            $0.productGroups = .nonCardProducts
            $0.separators = .emptySeparators
        }
    }
    
    func test_separators_shouldNotUpdateEmptySeparatorsWithMainAndAdditionalCards() {
        
        assert(.update(.mainWithAdditionalCards), on: .empty) {
           
            $0.selector = .init(items: [.card])
            $0.productGroups = .mainWithAdditionalCards
            $0.separators = .emptySeparators
        }
    }
    
    func test_separators_shouldNotUpdateEmptySeparatorsWithRegularAndAdditionalCards() {
        
        assert(.update(.regularWithAdditionalCards), on: .empty) {
           
            $0.selector = .init(items: [.card])
            $0.productGroups = .regularWithAdditionalCards
            $0.separators = .emptySeparators
        }
    }
    
    func test_separators_shouldNotUpdateEmptySeparatorsWithAdditionalCards() {
        
        assert(.update(.additionalCards), on: .empty) {
            
            $0.selector = .init(items: [.card])
            $0.productGroups = .additionalCards
            $0.separators = .emptySeparators
        }
    }
    
    func test_separators_shouldUpdateEmptyWithNonEmptyProducts() {
        
        assert(.update(.cards), on: .empty) {
            
            $0.selector = .init(items: [.card])
            $0.productGroups = .cards
            $0.separators = .separatorsForPreviewProducts
        }
    }
        
    func test_separators_shouldUpdateToMoreProductsFromNonEmpty() {
        
        assert(.update(.moreProducts), on: .cards) {
            
            $0.selector = .init(items: [.card, .account, .deposit, .loan])
            $0.productGroups = .moreProducts
            $0.separators = .separatorsForMoreProducts
        }
    }

    // MARK: - Spoiler Title
    
    func test_spoilerTitle_shouldNotUpdateForNonCardProducts() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.nonCardProducts))
        let spoilerTitle = reduce.state.spoilerTitle(for: .cards)
        
        XCTAssertEqual(spoilerTitle, nil)
    }
    
    func test_spoilerTitle_shouldNotUpdateForThreeCards() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.threeCards))
        let spoilerTitle = reduce.state.spoilerTitle(for: .threeCards)
        
        XCTAssertEqual(spoilerTitle, nil)
    }
    
    func test_spoilerTitle_shouldNotUpdateForAccountProductsFromEmpty() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.accountProducts))
        let spoilerTitle = reduce.state.spoilerTitle(for: .accountProducts)
        
        XCTAssertEqual(spoilerTitle, nil)
    }
    
    func test_spoilerTitle_shouldNotUpdateForDepositProductsFromEmpty() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.depositProducts))
        let spoilerTitle = reduce.state.spoilerTitle(for: .depositProducts)
        
        XCTAssertEqual(spoilerTitle, nil)
    }
    
    func test_spoilerTitle_shouldNotUpdateForLoanProductsFromEmpty() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.loanProducts))
        let spoilerTitle = reduce.state.spoilerTitle(for: .loanProducts)
        
        XCTAssertEqual(spoilerTitle, nil)
    }
    
    func test_spoilerTitle_shouldNotUpdateForEmptyWithEmptyProducts() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.cards))
        let spoilerTitle = reduce.state.spoilerTitle(for: .cards)
        
        XCTAssertEqual(spoilerTitle, .spoilerTitleForCardProducts)
    }
    
    func test_spoilerTitle_shouldUpdateWithAllCardProducts() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.allCardProducts))
        let spoilerTitle = reduce.state.spoilerTitle(for: .allCardProducts)
                
        XCTAssertEqual(spoilerTitle, .spoilerTitleForAllCardProducts)
    }
    
    func test_spoilerTitle_shouldUpdateWithAllCardProductsWithSticker() {
                
        let sut = makeSUT()
        
        let reduce = reduce(sut, event: .update(.allCardProductsWithSticker))
        let spoilerTitle = reduce.state.spoilerTitle(for: .allCardProductsWithSticker)
                
        XCTAssertEqual(spoilerTitle, .spoilerTitleForAllCardProductsWithSticker)
    }
    
    private typealias SUT = CarouselReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias Result = (State, Effect?)
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
    
    private func reduce(
        _ sut: SUT,
        _ needShowSticker: Bool = true,
        _ state: State = .init(products: .cards, needShowSticker: true),
        event: Event
    ) -> (state: State, effect: Effect?) {
        
        return sut.reduce(state, event)
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        _assertState(
            sut,
            event,
            on: state,
            updateStateToExpected: updateStateToExpected,
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ currentState: State,
        _ event: Event,
        reducedTo expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sut = sut ?? makeSUT()
        let (receivedState, _) = sut.reduce(currentState, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let receivedEffect = reduce(sut ?? makeSUT(), true, state, event: event).1
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)) state, but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}

private extension CarouselReducer.State {
    
    static let empty: Self = .init(products: [], needShowSticker: true)
    static let cards: Self = .init(products: .cards, needShowSticker: true)
    static let more: Self = .init(products: .moreProducts, needShowSticker: true)
    static let all: Self = .init(products: .cards + .moreProducts, needShowSticker: true)
    static let defaultCollapsed: Self = .init(products: .cards, needShowSticker: true)
    static let nonCardProducts: Self = .init(products: .nonCardProducts, needShowSticker: true)
}

extension CarouselReducer: Reducer { }
