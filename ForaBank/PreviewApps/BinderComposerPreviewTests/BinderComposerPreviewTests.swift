//
//  BinderComposerPreviewTests.swift
//  BinderComposerPreviewTests
//
//  Created by Igor Malyarov on 14.12.2024.
//

@testable import BinderComposerPreview
import XCTest

final class BinderComposerPreviewTests: XCTestCase {
    
    func test_init_shouldSetToNil() {
        
        let (sut, destinationSpy, sheetSpy) = makeSUT()
        
        XCTAssertEqual(destinationSpy.values, [nil])
        XCTAssertEqual(sheetSpy.values, [nil])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RootDomain.Binder
    private typealias NavigationSpy = ValueSpy<EquatableNavigation?>
    private typealias DestinationSpy = ValueSpy<EquatableDestination?>
    private typealias SheetSpy = ValueSpy<EquatableSheet?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        destinationSpy: DestinationSpy,
        sheetSpy: SheetSpy
    ) {
        let sut = SUT.default
        let navigationPublisher = sut.flow.$state.map(\.navigation)
        let destinationSpy = DestinationSpy(navigationPublisher.map { $0?.destination.map(self.equatable)})
        let sheetSpy = SheetSpy(navigationPublisher.map { $0?.sheet.map(self.equatable)})
        
        // TODO: - fix memory leaks
        // trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(destinationSpy, file: file, line: line)
        trackForMemoryLeaks(sheetSpy, file: file, line: line)
        
        return (sut, destinationSpy, sheetSpy)
    }
    
    private func equatable(
        _ navigation: RootDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .destination: return .destination
        case .sheet:       return .sheet
        }
    }
    
    private enum EquatableNavigation {
        
        case destination
        case sheet
    }
    
    private func equatable(
        _ navigation: RootDomain.Navigation.Destination
    ) -> EquatableDestination {
        
        switch navigation {
        case .content: return .content
        }
    }
    
    private enum EquatableDestination {
        
        case content
    }
    
    private func equatable(
        _ sheet: RootDomain.Navigation.Sheet
    ) -> EquatableSheet {
        
        switch sheet {
        case .content: return .content
        }
    }
    
    private enum EquatableSheet {
        
        case content
    }
}
