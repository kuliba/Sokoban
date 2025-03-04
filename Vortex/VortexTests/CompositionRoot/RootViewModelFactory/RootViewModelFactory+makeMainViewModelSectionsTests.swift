//
//  RootViewModelFactory+makeMainViewModelSectionsTests.swift
//  VortexTests
//
//  Created by Valentin Ozerov on 20.12.2024.
//

@testable import Vortex
import SwiftUI
import XCTest

final class RootViewModelFactory_makeMainViewModelSectionsTests: RootViewModelFactoryTests {
    
    func test_shouldMakeMainViewModelSections() {
        
        let (sut, _, _) = makeSUT()
        let bannersBinder = BannersBinder.immediate
        
        let sections = sut.makeMainViewModelSections(
            bannersBinder: bannersBinder,
            c2gFlag: .inactive,
            collateralLoanLandingFlag: .active
        )
        
        XCTAssertTrue(sections.count == 6)
        XCTAssertTrue(sections[0] is MainSectionProductsView.ViewModel)
        XCTAssertTrue(sections[1] is MainSectionFastOperationView.ViewModel)
        XCTAssertTrue(sections[2] is MainSectionPromoView.ViewModel)
        XCTAssertTrue(sections[3] is MainSectionCurrencyMetallView.ViewModel)
        XCTAssertTrue(sections[4] is MainSectionOpenProductView.ViewModel)
        XCTAssertTrue(sections[5] is MainSectionAtmView.ViewModel)
    }
    
    // MARK: - FastOperation
    
    func test_shouldMakeFastOperationSection_onInactiveC2GFlag() {
        
        let sections = makeMainViewModelSections(c2gFlag: .inactive)
        
        XCTAssertEqual(sections.fastOperationSections.count, 1)
    }
    
    func test_shouldMakeFastOperationSection_onActiveC2GFlag() {
        
        let sections = makeMainViewModelSections(c2gFlag: .active)
        
        XCTAssertEqual(sections.fastOperationSections.count, 1)
    }
    
    func test_shouldMakeFastOperationSectionItemsWithTitles_onInactiveC2GFlag() throws {
        
        let fastOperationSection = try fastOperationSection(c2gFlag: .inactive)
        
        XCTAssertNoDiff(fastOperationSection.titles, [
            FastOperationsTitles.qr,
            FastOperationsTitles.byPhone,
            FastOperationsTitles.utilityPayment,
            FastOperationsTitles.templates,
        ])
    }
    
    func test_shouldMakeFastOperationSectionItemsWithTitles_onActiveC2GFlag() throws {
        
        let fastOperationSection = try fastOperationSection(c2gFlag: .active)
        
        XCTAssertNoDiff(fastOperationSection.titles, [
            FastOperationsTitles.qr,
            FastOperationsTitles.uin,
            FastOperationsTitles.byPhone,
            FastOperationsTitles.utilityPayment,
            FastOperationsTitles.templates,
        ])
    }
    
    func test_shouldMakeScanQRFastOperationItemWithDesign_onInactiveC2GFlag() throws {
        
        let scanQR = try scanQRButton(c2gFlag: .inactive)
        
        XCTAssertNoDiff(scanQR.equatable, .init(
            icon: .init(
                image: .ic24BarcodeScanner2, 
                background: .circle
            ),
            orientation: .vertical
        ))
    }
    
    func test_shouldMakeScanQRFastOperationItemWithSpecificDesign_onActiveC2GFlag() throws {
        
        let scanQR = try scanQRButton(c2gFlag: .active)
        
        XCTAssertNoDiff(scanQR.equatable, .init(
            icon: .init(
                image: .ic24Qr,
                style: .color(.iconWhite),
                background: .circle,
                backgroundColor: .iconBlack
            ),
            orientation: .vertical
        ))
    }
    
    // MARK: - Helpers
    
    private func makeMainViewModelSections(
        _ sut: SUT? = nil,
        c2gFlag: C2GFlag,
        collateralLoanLandingFlag: CollateralLoanLandingFlag = .inactive,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [MainSectionViewModel] {
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
        return sut.makeMainViewModelSections(
            bannersBinder: .immediate,
            c2gFlag: c2gFlag,
            collateralLoanLandingFlag: collateralLoanLandingFlag
        )
    }
    
    private func fastOperationSection(
        _ sut: SUT? = nil,
        c2gFlag: C2GFlag,
        collateralLoanLandingFlag: CollateralLoanLandingFlag = .inactive,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> MainSectionFastOperationView.ViewModel {
        
        let sections = makeMainViewModelSections(
            sut,
            c2gFlag: c2gFlag,
            collateralLoanLandingFlag: collateralLoanLandingFlag,
            file: file, line: line
        )
        
        return try XCTUnwrap(
            sections.fastOperationSection,
            "Expected FastOperation Section, but got nil instead.",
            file: file, line: line
        )
    }
    
    private func scanQRButton(
        c2gFlag: C2GFlag,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ButtonIconTextView.ViewModel {
        
        let section = try fastOperationSection(c2gFlag: c2gFlag, file: file, line: line)
        
        return try XCTUnwrap(
            section.button(withTitle: FastOperationsTitles.qr),
            file: file, line: line
        )
    }
}

// MARK: - DSL

private extension Array where Element == MainSectionViewModel {
    
    var fastOperationSection: MainSectionFastOperationView.ViewModel? {
        
        fastOperationSections.first
    }
    
    var fastOperationSections: [MainSectionFastOperationView.ViewModel] {
        
        compactMap { $0 as? MainSectionFastOperationView.ViewModel }
    }
}

private extension MainSectionFastOperationView.ViewModel {
    
    var titles: [String] { items.map(\.title.text) }
    
    func button(
        withTitle title: String
    ) -> ButtonIconTextView.ViewModel? {
        
        items.first { $0.title.text == title }
    }
}

private extension ButtonIconTextView.ViewModel {
    
    var equatable: EquatableModel {
        
        return .init(icon: equatableIcon, orientation: equatableOrientation)
    }
    
    struct EquatableModel: Equatable {
        
        let icon: Icon
        let orientation: Orientation
        
        struct Icon: Equatable {
            
            let image: Image
            var style: Style = .color(.iconBlack)
            let background: Background
            var backgroundColor: Color = .mainColorsGrayLightest
            var badge: Badge? = nil
            
            enum Style: Equatable {
                
                case original
                case color(Color)
            }
            
            enum Background {
                
                case circleSmall
                case circle
                case square
            }
            
            struct Badge: Equatable {
                
                let text: Text
                var backgroundColor: Color
                var textColor: Color
                
                struct Text: Equatable {
                    
                    let title: String
                    let font: Font
                    let fontWeight: Font.Weight
                }
            }
        }
        
        enum Orientation {
            
            case horizontal, vertical
        }
    }
    
    var equatableIcon: EquatableModel.Icon {
        
        return .init(
            image: icon.image,
            style: icon.equatableStyle,
            background: icon.equatableBackground,
            backgroundColor: icon.backgroundColor,
            badge: icon.equatableBadge
        )
    }
    
    var equatableOrientation: EquatableModel.Orientation {
        
        switch orientation {
        case .horizontal: return .horizontal
        case .vertical: return .vertical
        }
    }
}

private extension ButtonIconTextView.ViewModel.Icon {
    
    var equatableStyle: ButtonIconTextView.ViewModel.EquatableModel.Icon.Style {
        
        switch style {
        case let .color(color): return .color(color)
        case .original:         return .original
        }
    }
    
    var equatableBackground: ButtonIconTextView.ViewModel.EquatableModel.Icon.Background {
        
        switch background {
        case .circle:      return .circle
        case .circleSmall: return .circleSmall
        case .square:      return .square
        }
    }
    
    var equatableBadge: ButtonIconTextView.ViewModel.EquatableModel.Icon.Badge? {
        
        return badge.map {
            
            return .init(text: $0.equatableText, backgroundColor: $0.backgroundColor, textColor: $0.textColor)
        }
    }
}

private extension ButtonIconTextView.ViewModel.Icon.Badge {
    
    var equatableText: ButtonIconTextView.ViewModel.EquatableModel.Icon.Badge.Text {
        
        return .init(title: text.title, font: text.font, fontWeight: text.fontWeight)
    }
}
