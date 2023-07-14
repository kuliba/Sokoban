//
//  MakeToolbarTests.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

@testable import TextFieldUI
import XCTest

final class MakeToolbarTests: XCTestCase {
    
    func test_makeToolbar_setsDefaultValues() throws {
        
        let doneButton = makeUIBarButtonItem(title: "DONE")
        let closeButton: UIBarButtonItem? = nil
        let toolbar = ToolbarFactory.makeToolbar(
            doneButton: doneButton,
            closeButton: closeButton
        )
        
        XCTAssertNoDiff(toolbar.frame.minX, 0)
        XCTAssertNoDiff(toolbar.frame.minY, 0)
        XCTAssertNoDiff(toolbar.frame.height, 44)
        XCTAssertNoDiff(toolbar.barStyle, .default)
        XCTAssertNoDiff(toolbar.barTintColor, .white.withAlphaComponent(0))
        XCTAssert(toolbar.clipsToBounds)
        
        let toolbarDoneButton = try XCTUnwrap(toolbar.items?.last)
        XCTAssertNoDiff(toolbarDoneButton.tintColor, .init(hexString: "#1C1C1C"))
        XCTAssertNoDiff(toolbarDoneButton.font, .systemFont(ofSize: 18, weight: .bold))
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
        
        XCTAssertNoDiff(toolbar.frame, .init(x: 0, y: 0, width: 333, height: 66))
        XCTAssertNoDiff(toolbar.barStyle, .default)
        XCTAssertNoDiff(toolbar.barTintColor, .white.withAlphaComponent(0))
        XCTAssert(toolbar.clipsToBounds)
        
        let items = try XCTUnwrap(toolbar.items)
        XCTAssertNoDiff(items.count, 2)
        XCTAssertNoDiff(items.map(\.tintColor), [nil, .red])
        
        let toolbarDoneButton = try XCTUnwrap(items.last)
        XCTAssertNoDiff(toolbarDoneButton.tintColor, .red)
        XCTAssertNoDiff(toolbarDoneButton.title, "DONE")
        XCTAssertNoDiff(toolbarDoneButton.font, .systemFont(ofSize: 44))
        
        let flexibleSpace = try XCTUnwrap(items.first)
        XCTAssertNil(flexibleSpace.tintColor)
        XCTAssertNil(flexibleSpace.title)
        XCTAssertNoDiff(flexibleSpace.style, .plain)
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
        
        XCTAssertNoDiff(toolbar.frame, .init(x: 0, y: 0, width: 333, height: 66))
        XCTAssertNoDiff(toolbar.barStyle, .default)
        XCTAssertNoDiff(toolbar.barTintColor, .white.withAlphaComponent(0))
        XCTAssert(toolbar.clipsToBounds)
        
        let items = try XCTUnwrap(toolbar.items)
        XCTAssertNoDiff(items.count, 3)
        XCTAssertNoDiff(items.map(\.tintColor), [.red, nil, .red])
        
        let toolbarDoneButton = try XCTUnwrap(items.last)
        XCTAssertNoDiff(toolbarDoneButton.tintColor, .red)
        XCTAssertNoDiff(toolbarDoneButton.title, "DONE")
        XCTAssertNoDiff(toolbarDoneButton.font, .systemFont(ofSize: 44))
        
        let toolbarCloseButton = try XCTUnwrap(items.first)
        XCTAssertNoDiff(toolbarCloseButton.tintColor, .red)
        XCTAssertNoDiff(toolbarCloseButton.title, "CLOSE")
        
        let flexibleSpace = try XCTUnwrap(items.dropFirst().first)
        XCTAssertNil(flexibleSpace.tintColor)
        XCTAssertNil(flexibleSpace.title)
        XCTAssertNoDiff(flexibleSpace.style, .plain)
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
