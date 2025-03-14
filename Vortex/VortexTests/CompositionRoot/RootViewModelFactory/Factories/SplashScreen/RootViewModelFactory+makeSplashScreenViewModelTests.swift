//
//  RootViewModelFactory+makeSplashScreenViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 14.03.2025.
//

import SplashScreenUI
@testable import Vortex
import XCTest

final class RootViewModelFactory_makeSplashScreenViewModelTests: RootViewModelFactoryTests {
    
    // MARK: - phase
    
    func test_shouldSetSplashPhaseToHidden_onInactiveFlag() {
        
        let (sut, _,_) = makeSUT()
        let splash = sut.makeSplashScreenViewModel(flag: .init(.inactive))
        
        XCTAssertNoDiff(splash.state.phase, .hidden)
    }
    
    func test_shouldSetSplashPhaseToCover_onActiveFlag() {
        
        let (sut, _,_) = makeSUT()
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.phase, .cover)
    }
    
    // MARK: - Text without user name
    
    func test_shouldSetSplashTextToMorning_onActiveFlag_Tokyo() throws {
        
        let sut = try makeSUT(calendar: .tokyo, hour: 10, minute: 15)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Tokyo() throws {
        
        let sut = try makeSUT(calendar: .tokyo, hour: 13, minute: 33)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Tokyo() throws {
        
        let sut = try makeSUT(calendar: .tokyo, hour: 19, minute: 45)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Tokyo() throws {
        
        let sut = try makeSUT(calendar: .tokyo, hour: 1, minute: 20)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    func test_shouldSetSplashTextToMorning_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: .paris, hour: 10, minute: 5)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: .paris, hour: 13, minute: 45)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: .paris, hour: 19, minute: 33)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: .paris, hour: 1, minute: 33)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    // MARK: - Text without user name
    
    func test_shouldSetSplashTextWithCustomName_onActiveFlag_Paris() throws {
        
        let (firstName, customName) = (anyMessage(), anyMessage())
        let model = try withClientInfo(firstName: firstName, customName: customName)
        let sut = try makeSUT(calendar: .paris, hour: 10, minute: 20, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(customName)!")
    }
    
    func test_shouldSetSplashTextWithCustomName_onActiveFlag_Tokyo() throws {
        
        let (firstName, customName) = (anyMessage(), anyMessage())
        let model = try withClientInfo(firstName: firstName, customName: customName)
        let sut = try makeSUT(calendar: .tokyo, hour: 2, minute: 15, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи,\n\(customName)!")
    }
    
    func test_shouldSetSplashTextWithFirstName_onNilCustomName_onActiveFlag_Paris() throws {
        
        let firstName = anyMessage()
        let model = try withClientInfo(firstName: firstName, customName: nil)
        let sut = try makeSUT(calendar: .paris, hour: 10, minute: 20, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(firstName)!")
    }
    
    func test_shouldSetSplashTextWithFirstName_onNilCustomName_onActiveFlag_Tokyo() throws {
        
        let firstName = anyMessage()
        let model = try withClientInfo(firstName: firstName, customName: nil)
        let sut = try makeSUT(calendar: .tokyo, hour: 20, minute: 45, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер,\n\(firstName)!")
    }
    
    // MARK: - Settings
    
    func test_shouldDeliverDefaultSettings_onEmptyCache_onActiveFlag() throws {
        
        let sut = try makeSUT(calendar: .tokyo, hour: 20, minute: 45)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings, defaultSettings())
    }
    
    // MARK: - Helpers Tests
    
    func test_makeTime() throws {
        
        let calendar: Calendar = .tokyo
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        let timeString = calendar.currentTimeString { date }
        
        XCTAssertNoDiff(timeString, "10:20")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        calendar: Calendar,
        hour: Int,
        minute: Int,
        model: Model = .mockWithEmptyExcept(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> SUT {
        
        let date = try makeTime(hour: hour, minute: minute, calendar: calendar)
        let sut = makeSUT(calendar: calendar, currentDate: { date }, model: model, file: file, line: line).sut
        
        return sut
    }
    
    private func withClientInfo(
        firstName: String,
        customName: String? = nil
    ) throws -> Model {
        
        let info = makeClientInfoData(firstName: firstName, customName: customName)
        let localAgent = try LocalAgentStub(value: info)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        
        return model
    }
    
    private func defaultSettings() -> SplashScreenState.Settings {
        
        return .init(
            image: .init("splash"),
            bank: .init(
                color: .init(hex: "FFFFFF"),
                shadow: .init(color: .init(hex: "000000"), opacity: 0.25, radius: 64, x: 0, y: 4)
            ),
            name: .init(
                color: .init(hex: "FFFFFF"),
                shadow: .init(color: .init(hex: "000000"), opacity: 0.25, radius: 4, x: 0, y: 4)
            ),
            text: .init(
                color: .init(hex: "FFFFFF"),
                size: 24,
                value: "Добрый вечер!",
                shadow: .init(color: .init(hex: "000000"), opacity: 0.25, radius: 12, x: 0, y: 4)
            ),
            subtext: nil
        )
    }
    
    private func makeCodableSplashScreenStorage(
        entries: [String: CodableSplashScreenStorage.Entry]
    ) -> CodableSplashScreenStorage {
        
        return .init(entries: entries)
    }
    
    private func makeEntry(
        items: [CodableSplashScreenSettings],
        serial: String = anyMessage()
    ) -> CodableSplashScreenStorage.Entry {
        
        return .init(items: items, serial: serial)
    }
    
    private func makeCodableSplashScreenSettings(
        bank: CodableSplashScreenSettings.Logo? = nil,
        name: CodableSplashScreenSettings.Logo? = nil,
        text: CodableSplashScreenSettings.Text? = nil,
        subtext: CodableSplashScreenSettings.Text? = nil,
        imageData: CodableSplashScreenSettings.ImageData = .none,
        link: String = anyMessage(),
        period: String = anyMessage()
    ) -> CodableSplashScreenSettings {
        
        return .init(
            bank: bank ?? makeLogo(),
            name: name ?? makeLogo(),
            text: text ?? makeText(),
            subtext: subtext,
            imageData: imageData,
            link: link,
            period: period
        )
    }
    
    private func makeLogo(
        color: String = anyMessage(),
        shadow: CodableSplashScreenSettings.Shadow? = nil
    ) -> CodableSplashScreenSettings.Logo {
        
        return .init(color: color, shadow: shadow ?? makeShadow())
    }
    
    private func makeText(
        color: String = anyMessage(),
        size: CGFloat = .random(in: 1..<100),
        value: String = anyMessage(),
        shadow: CodableSplashScreenSettings.Shadow? = nil
    ) -> CodableSplashScreenSettings.Text {
        
        return .init(color: color, size: size, value: value, shadow: shadow ?? makeShadow())
    }
    
    private func makeShadow(
        color: String = anyMessage(),
        opacity: Double = .random(in: 1..<100),
        radius: CGFloat = .random(in: 1..<100),
        x: CGFloat = .random(in: 1..<100),
        y: CGFloat = .random(in: 1..<100)
    ) -> CodableSplashScreenSettings.Shadow {
        
        return .init(color: color, opacity: opacity, radius: radius, x: x, y: y)
    }
}

extension XCTestCase {
    
    func makeTime(
        hour: Int,
        minute: Int,
        calendar: Calendar = .init(identifier: .gregorian),
        timeZone: TimeZone? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Date {
        
        var calendar = calendar
        if let timeZone { calendar.timeZone = timeZone }
        
        var dateComponents = DateComponents()
        dateComponents.year = 1970
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        let dateInTimeZone = try XCTUnwrap(calendar.date(from: dateComponents), "Expected date, but got nil instead.", file: file, line: line)
        
        return dateInTimeZone
    }
}

extension Calendar {
    
    static var paris: Calendar {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        return calendar
    }
    
    static var tokyo: Calendar {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }
}
