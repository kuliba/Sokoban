//
//  ProvidersTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 08.12.2024.
//

@testable import Vortex
import VortexTools
import RemoteServices
import XCTest

final class ProvidersTests: XCTestCase {
    
    func test_shouldDeliverEmptyOnEmpty() {
        
        XCTAssertTrue(map([]).isEmpty)
    }
    
    func test_shouldSortProvidersCorrectly() {
        
        let providers = [
            makeProvider(id: "2", inn: "456", name: "Beta"),
            makeProvider(id: "3", inn: "789", name: "Alpha"),
            makeProvider(id: "1", inn: "123", name: "Alpha"),
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.id), ["1", "3", "2"])
        XCTAssertEqual(operators.map(\.inn), ["123", "789", "456"])
        XCTAssertEqual(operators.map(\.name), ["Alpha" ,"Alpha", "Beta"])
    }
    
    func test_shouldSortSingleProvider() {
        
        let providers = [
            makeProvider(id: "1", inn: "999", name: "Single")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.count, 1)
        XCTAssertEqual(operators[0].id, "1")
        XCTAssertEqual(operators[0].inn, "999")
        XCTAssertEqual(operators[0].name, "Single")
        XCTAssertEqual(operators[0].sortedOrder, 0)
    }
    
    func test_shouldSortProvidersWithIdenticalNamesAndINNs() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "2", inn: "123", name: "Alpha"),
            makeProvider(id: "3", inn: "123", name: "Alpha")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.count, 3)
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithSameNameDifferentINNs() {
        
        let providers = [
            makeProvider(id: "1", inn: "456", name: "Alpha"),
            makeProvider(id: "2", inn: "123", name: "Alpha"),
            makeProvider(id: "3", inn: "789", name: "Alpha")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.count, 3)
        XCTAssertEqual(operators.map(\.inn), ["123", "456", "789"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithSameINNDifferentNames() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Beta"),
            makeProvider(id: "2", inn: "123", name: "Alpha"),
            makeProvider(id: "3", inn: "123", name: "Gamma")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.count, 3)
        XCTAssertEqual(operators.map(\.name), ["Alpha", "Beta", "Gamma"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithDifferentPriority() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "2", inn: "456", name: "Бета"),
            makeProvider(id: "3", inn: "789", name: "Gamma")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.count, 3)
        XCTAssertEqual(operators.map(\.name), ["Бета", "Alpha", "Gamma"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithCustomPriorityFunction() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "2", inn: "456", name: "Beta"),
            makeProvider(id: "3", inn: "789", name: "Gamma")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.count, 3)
        XCTAssertEqual(operators.map(\.name), ["Alpha", "Beta", "Gamma"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithNamesDifferingOnlyByCase() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "alpha"),
            makeProvider(id: "2", inn: "456", name: "Alpha"),
            makeProvider(id: "3", inn: "789", name: "ALPHA")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["ALPHA", "Alpha", "alpha"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithEmptyNames() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: ""),
            makeProvider(id: "2", inn: "456", name: "Alpha"),
            makeProvider(id: "3", inn: "789", name: "")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["", "", "Alpha"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithEmptyINNs() {
        
        let providers = [
            makeProvider(id: "3", inn: "", name: "Alpha"),
            makeProvider(id: "3", inn: "456", name: "Beta"),
            makeProvider(id: "1", inn: "", name: "Gamma")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.inn), ["", "456", ""])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithSpecialCharactersInNamesAndINNs() {
        
        let providers = [
            makeProvider(id: "1", inn: "@123", name: "Alpha!"),
            makeProvider(id: "2", inn: "#456", name: "Beta@"),
            makeProvider(id: "3", inn: "$789", name: "Gamma#")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Alpha!", "Beta@", "Gamma#"])
        XCTAssertEqual(operators.map(\.inn), ["@123", "#456", "$789"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithMixedUnicodeCharacters() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Альфа"),
            makeProvider(id: "2", inn: "456", name: "Beta"),
            makeProvider(id: "3", inn: "789", name: "Гамма")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Альфа", "Гамма", "Beta"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldHandleDuplicateProviders() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "1", inn: "123", name: "Alpha")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.count, 3)
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldAssignCorrectSortedOrder() {
        
        let providers = [
            makeProvider(id: "3", inn: "789", name: "Gamma"),
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "2", inn: "456", name: "Beta")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithNamesContainingBothCyrillicAndLatinCharacters() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "AlphaБ"),
            makeProvider(id: "2", inn: "456", name: "БетаAlpha"),
            makeProvider(id: "3", inn: "789", name: "GammaБ")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["БетаAlpha", "AlphaБ", "GammaБ"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithNamesContainingNumbersAndSpecialCharacters() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha1!"),
            makeProvider(id: "2", inn: "456", name: "Alpha!2"),
            makeProvider(id: "3", inn: "789", name: "Alpha#3")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Alpha1!", "Alpha!2", "Alpha#3"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithNamesHavingDiacritics() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "2", inn: "456", name: "Àlpha"),
            makeProvider(id: "3", inn: "789", name: "Álpha")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Alpha", "Àlpha", "Álpha"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithBothNamesAndINNsEmpty() {
        
        let providers = [
            makeProvider(id: "1", inn: "", name: ""),
            makeProvider(id: "2", inn: "", name: ""),
            makeProvider(id: "3", inn: "", name: "")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["", "", ""])
        XCTAssertEqual(operators.map(\.inn), ["", "", ""])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithSomeEmptyNamesAndSomeEmptyINNs() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "2", inn: "456", name: ""),
            makeProvider(id: "3", inn: "", name: "Beta"),
            makeProvider(id: "4", inn: "789", name: "")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["", "", "Alpha", "Beta"])
        XCTAssertEqual(operators.map(\.inn), ["456", "789", "123", ""])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2, 3])
    }
    
    func test_shouldSortProvidersWithNamesBeingSubstrings() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha"),
            makeProvider(id: "2", inn: "456", name: "AlphaBeta"),
            makeProvider(id: "3", inn: "789", name: "AlphaGamma")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Alpha", "AlphaBeta", "AlphaGamma"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithNamesContainingEmoji() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Alpha😊"),
            makeProvider(id: "2", inn: "456", name: "Beta🚀"),
            makeProvider(id: "3", inn: "789", name: "Gamma🎉")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Alpha😊", "Beta🚀", "Gamma🎉"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithAllCharactersHavingSamePriority() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "aaa"),
            makeProvider(id: "2", inn: "456", name: "aab"),
            makeProvider(id: "3", inn: "789", name: "aac")
        ]
        
        let uniformPriority: (Character) -> Int = { _ in 1 }
        
        let operators = [CodableServicePaymentOperator](providers: providers, priority: uniformPriority)
        
        XCTAssertEqual(operators.map(\.name), ["aaa", "aab", "aac"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithNamesAndINNsHavingMixedCharacterTypes() {
        
        let providers = [
            makeProvider(id: "1", inn: "A1B2", name: "Alpha1"),
            makeProvider(id: "2", inn: "A1B3", name: "Alpha2"),
            makeProvider(id: "3", inn: "A1B1", name: "Alpha3")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Alpha1", "Alpha2", "Alpha3"])
        XCTAssertEqual(operators.map(\.inn), ["A1B2", "A1B3", "A1B1"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    func test_shouldSortProvidersWithNamesContainingAccentedCharacters() {
        
        let providers = [
            makeProvider(id: "1", inn: "123", name: "Álpha"),
            makeProvider(id: "2", inn: "456", name: "Alphá"),
            makeProvider(id: "3", inn: "789", name: "Alpha")
        ]
        
        let operators = map(providers)
        
        XCTAssertEqual(operators.map(\.name), ["Alpha", "Alphá", "Álpha"])
        XCTAssertEqual(operators.map(\.sortedOrder), [0, 1, 2])
    }
    
    // MARK: - Helpers
    
    private typealias ServicePaymentProvider = RemoteServices.ResponseMapper.ServicePaymentProvider
    
    private func map(
        _ providers: [ServicePaymentProvider]
    ) -> [CodableServicePaymentOperator] {
        
        return .init(providers: providers)
    }
    
    private func makeProvider(
        id: String,
        inn: String,
        name: String
    ) -> ServicePaymentProvider {
        
        makeServicePaymentProvider(id: id, inn: inn, name: name)
    }
}
