//
//  MakeToolbarTests.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

@testable import TextFieldRegularComponent
import XCTest

final class MakeToolbarTests: XCTestCase {
    
    func test_makeToolbar_setsDefaultValues() throws {
        
        let doneButton = makeUIBarButtonItem(title: "DONE")
        let closeButton: UIBarButtonItem? = nil
        let toolbar = ToolbarFactory.makeToolbar(
            doneButton: doneButton,
            closeButton: closeButton
        )
        
        XCTAssertEqual(toolbar.frame.minX, 0)
        XCTAssertEqual(toolbar.frame.minY, 0)
        XCTAssertEqual(toolbar.frame.height, 44)
        XCTAssertEqual(toolbar.barStyle, .default)
        XCTAssertEqual(toolbar.barTintColor, .white.withAlphaComponent(0))
        XCTAssert(toolbar.clipsToBounds)
        
        let toolbarDoneButton = try XCTUnwrap(toolbar.items?.last)
        XCTAssertEqual(toolbarDoneButton.tintColor, .init(hexString: "#1C1C1C"))
        XCTAssertEqual(toolbarDoneButton.font, .systemFont(ofSize: 18, weight: .bold))
    }
    
    func test_makeToolbar_withoutCloseButton() throws {
        
        let doneButton = makeUIBarButtonItem(title: "DONE")
        let closeButton: UIBarButtonItem? = nil
        let toolbar = ToolbarFactory.makeToolbar(
            color: .red,
            font: .systemFont(ofSize: 44),
            width: 333,
            height: 66,
            doneButton: doneButton,
            closeButton: closeButton
        )
        
        XCTAssertEqual(toolbar.frame, .init(x: 0, y: 0, width: 333, height: 66))
        XCTAssertEqual(toolbar.barStyle, .default)
        XCTAssertEqual(toolbar.barTintColor, .white.withAlphaComponent(0))
        XCTAssert(toolbar.clipsToBounds)
        
        let items = try XCTUnwrap(toolbar.items)
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items.map(\.tintColor), [nil, .red])
        
        let toolbarDoneButton = try XCTUnwrap(items.last)
        XCTAssertEqual(toolbarDoneButton.tintColor, .red)
        XCTAssertEqual(toolbarDoneButton.title, "DONE")
        XCTAssertEqual(toolbarDoneButton.font, .systemFont(ofSize: 44))
        
        let flexibleSpace = try XCTUnwrap(items.first)
        XCTAssertNil(flexibleSpace.tintColor)
        XCTAssertNil(flexibleSpace.title)
        XCTAssertEqual(flexibleSpace.style, .plain)
        XCTAssert(flexibleSpace.debugDescription.contains("systemItem=FlexibleSpace"))
    }
    
    func test_makeToolbar_withCloseButton() throws {
        
        let doneButton = makeUIBarButtonItem(title: "DONE")
        let closeButton = makeUIBarButtonItem(title: "CLOSE")
        let toolbar = ToolbarFactory.makeToolbar(
            color: .red,
            font: .systemFont(ofSize: 44),
            width: 333,
            height: 66,
            doneButton: doneButton,
            closeButton: closeButton
        )
        
        XCTAssertEqual(toolbar.frame, .init(x: 0, y: 0, width: 333, height: 66))
        XCTAssertEqual(toolbar.barStyle, .default)
        XCTAssertEqual(toolbar.barTintColor, .white.withAlphaComponent(0))
        XCTAssert(toolbar.clipsToBounds)
        
        let items = try XCTUnwrap(toolbar.items)
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items.map(\.tintColor), [.red, nil, .red])
        
        let toolbarDoneButton = try XCTUnwrap(items.last)
        XCTAssertEqual(toolbarDoneButton.tintColor, .red)
        XCTAssertEqual(toolbarDoneButton.title, "DONE")
        XCTAssertEqual(toolbarDoneButton.font, .systemFont(ofSize: 44))
        
        let toolbarCloseButton = try XCTUnwrap(items.first)
        XCTAssertEqual(toolbarCloseButton.tintColor, .red)
        XCTAssertEqual(toolbarCloseButton.title, "CLOSE")
        
        let flexibleSpace = try XCTUnwrap(items.dropFirst().first)
        XCTAssertNil(flexibleSpace.tintColor)
        XCTAssertNil(flexibleSpace.title)
        XCTAssertEqual(flexibleSpace.style, .plain)
        XCTAssert(flexibleSpace.debugDescription.contains("systemItem=FlexibleSpace"))
    }
    
    // MARK: - Helpers
    
    private func makeUIBarButtonItem(title: String) -> UIBarButtonItem {
        
        .init(title: title)
    }
}

private extension UIBarButtonItem {
    
    var font: UIFont? {
        
        titleTextAttributes(for: .normal)?[.font] as? UIFont
    }
}
