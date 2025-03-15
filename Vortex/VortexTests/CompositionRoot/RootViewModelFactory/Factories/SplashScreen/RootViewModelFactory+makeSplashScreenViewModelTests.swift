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
        let splash = sut.makeSplashScreenViewModel(flag: .inactive)
        
        XCTAssertNoDiff(splash.state.phase, .hidden)
    }
    
    func test_shouldSetSplashPhaseToCover_onActiveFlag() {
        
        let (sut, _,_) = makeSUT()
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.phase, .cover)
    }
    
    // MARK: - Text without user name
    
    func test_shouldSetSplashTextToMorning_onActiveFlag_Tokyo() throws {
        
        let (_, hour, minute) = morning()
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Tokyo() throws {
        
        let (_, hour, minute) = day()
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Tokyo() throws {
        
        let (_, hour, minute) = evening()
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Tokyo() throws {
        
        let (_, hour, minute) = night()
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    func test_shouldSetSplashTextToMorning_onActiveFlag_Paris() throws {
        
        let (_, hour, minute) = morning()
        let sut = try makeSUT(calendar: .paris, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Paris() throws {
        
        let (_, hour, minute) = day()
        let sut = try makeSUT(calendar: .paris, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Paris() throws {
        
        let (_, hour, minute) = evening()
        let sut = try makeSUT(calendar: .paris, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Paris() throws {
        
        let (_, hour, minute) = night()
        let sut = try makeSUT(calendar: .paris, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    // MARK: - Text without user name
    
    func test_shouldSetSplashTextWithCustomName_onActiveFlag_Paris() throws {
        
        let (_, hour, minute) = morning()
        let (firstName, customName) = (anyMessage(), anyMessage())
        let model = try withClientInfo(firstName: firstName, customName: customName)
        let sut = try makeSUT(calendar: .paris, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(customName)!")
    }
    
    func test_shouldSetSplashTextWithCustomName_onActiveFlag_Tokyo() throws {
        
        let (_, hour, minute) = night()
        let (firstName, customName) = (anyMessage(), anyMessage())
        let model = try withClientInfo(firstName: firstName, customName: customName)
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи,\n\(customName)!")
    }
    
    func test_shouldSetSplashTextWithFirstName_onNilCustomName_onActiveFlag_Paris() throws {
        
        let (_, hour, minute) = morning()
        let firstName = anyMessage()
        let model = try withClientInfo(firstName: firstName, customName: nil)
        let sut = try makeSUT(calendar: .paris, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(firstName)!")
    }
    
    func test_shouldSetSplashTextWithFirstName_onNilCustomName_onActiveFlag_Tokyo() throws {
        
        let (_, hour, minute) = evening()
        let firstName = anyMessage()
        let model = try withClientInfo(firstName: firstName, customName: nil)
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер,\n\(firstName)!")
    }
    
    // MARK: - Settings
    
    func test_shouldDeliverDefaultSettings_onEmptyCache_onActiveFlag_morning() throws {
        
        let (_, hour, minute) = morning()
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings, defaultSettings(with: "Доброе утро!"))
    }
    
    func test_shouldDeliverDefaultSettings_onEmptyCache_onActiveFlag_evening() throws {
        
        let (_, hour, minute) = evening()
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings, defaultSettings(with: "Добрый вечер!"))
    }
    
    func test_shouldDeliverDefaultSettings_onCacheWithNonMatchingPeriod_onActiveFlag() throws {
        
        let (_, hour, minute) = evening()
        let (nonMatchingPeriod, _,_) = day()
        let cached = try makeCodableSplashScreenSettings(period: nonMatchingPeriod)
        let storage = makeCodableSplashScreenStorage(
            entries: [nonMatchingPeriod: makeEntry(items: [cached])]
        )
        let localAgent = try LocalAgentStub(value: storage)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        // evening
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings, defaultSettings())
    }
    
    func test_shouldDeliverDefaultSettings_onCacheWithMissingImageData_onActiveFlag() throws {
        
        let (period, hour, minute) = evening()
        let cached = try makeCodableSplashScreenSettings(
            imageData: .missing,
            period: period
        )
        let storage = makeCodableSplashScreenStorage(
            entries: [period: makeEntry(items: [cached])]
        )
        let localAgent = try LocalAgentStub(value: storage)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings, defaultSettings())
    }
    
    func test_shouldDeliverDefaultSettings_onCacheWithNonImageData_onActiveFlag() throws {
        
        let (period, hour, minute) = evening()
        let cached = try makeCodableSplashScreenSettings(
            imageData: .data(.init(anyMessage().utf8)),
            period: period
        )
        let storage = makeCodableSplashScreenStorage(
            entries: [period: makeEntry(items: [cached])]
        )
        let localAgent = try LocalAgentStub(value: storage)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        
        XCTAssertNoDiff(splash.state.settings, defaultSettings())
    }
    
    func test_shouldDeliverCachedSettings_onActiveFlag() throws {
        
        let (period, hour, minute) = evening()
        let text = anyMessage()
        let cached = try makeCodableSplashScreenSettings(
            logo: makeLogo(color: "123456"),
            text: makeText(color: "345678", value: text),
            footer: makeLogo(color: "234567"),
            period: period
        )
        let storage = makeCodableSplashScreenStorage(
            entries: [period: makeEntry(items: [cached])]
        )
        let localAgent = try LocalAgentStub(value: storage)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        let settings = splash.state.settings
        
        XCTAssertNoDiff(settings.text.value, text)
        XCTAssertNoDiff(settings.logo.color, .init(hex: "123456"))
        XCTAssertNoDiff(settings.text.color, .init(hex: "345678"))
        XCTAssertNoDiff(settings.footer.color, .init(hex: "234567"))
    }
    
    func test_shouldDeliverCachedSettingsWithSubText_onActiveFlag() throws {
        
        let (period, hour, minute) = evening()
        let subtext = anyMessage()
        let cached = try makeCodableSplashScreenSettings(
            subtext: makeText(color: "456789", value: subtext),
            period: period
        )
        let storage = makeCodableSplashScreenStorage(
            entries: [period: makeEntry(items: [cached])]
        )
        let localAgent = try LocalAgentStub(value: storage)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let sut = try makeSUT(calendar: .tokyo, hour: hour, minute: minute, model: model)
        let splash = makeSplashScreenViewModel(sut)
        let settings = splash.state.settings
        
        XCTAssertNoDiff(settings.subtext?.color, .init(hex: "456789"))
    }
    
    // MARK: - Helpers Tests
    
    func test_makeTime() throws {
        
        let calendar: Calendar = .tokyo
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        let timeString = calendar.currentTimeString { date }
        
        XCTAssertNoDiff(timeString, "10:20")
    }
    
    // MARK: - Helpers
    
    private typealias Splash = SplashScreenViewModel
    
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
    
    private func makeSplashScreenViewModel(
        _ sut: SUT,
        flag: SplashScreenFlag = .active
    ) -> Splash {
        
        sut.makeSplashScreenViewModel(flag: flag)
    }
    
    private func morning() -> (period: String, hour: Int, minute: Int) {
        
        return ("MORNING", hour: .random(in: 4...11), minute: .random(in: 0...59))
    }
    
    private func day() -> (period: String, hour: Int, minute: Int) {
        
        return ("DAY", hour: .random(in: 12...17), minute: .random(in: 0...59))
    }
    
    private func evening() -> (period: String, hour: Int, minute: Int) {
        
        return ("EVENING", hour: .random(in: 18...23), minute: .random(in: 0...59))
    }
    
    private func night() -> (period: String, hour: Int, minute: Int) {
        
        return ("NIGHT", hour: .random(in: 0...3), minute: .random(in: 0...59))
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
    
    private func defaultSettings(
        with textValue: String = "Добрый вечер!"
    ) -> SplashScreenState.Settings {
        
        return .init(
            image: .init("splash"),
            logo: .init(
                color: .init(hex: "FFFFFF"),
                shadow: .init(color: .init(hex: "000000"), opacity: 0.25, radius: 64, x: 0, y: 4)
            ),
            text: .init(
                color: .init(hex: "FFFFFF"),
                size: 24,
                value: textValue,
                shadow: .init(color: .init(hex: "000000"), opacity: 0.25, radius: 12, x: 0, y: 4)
            ),
            subtext: nil,
            footer: .init(
                color: .init(hex: "FFFFFF"),
                shadow: .init(color: .init(hex: "000000"), opacity: 0.25, radius: 4, x: 0, y: 4)
            )
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
        logo: CodableSplashScreenSettings.Logo? = nil,
        text: CodableSplashScreenSettings.Text? = nil,
        subtext: CodableSplashScreenSettings.Text? = nil,
        footer: CodableSplashScreenSettings.Logo? = nil,
        imageData: CodableSplashScreenSettings.ImageData? = nil,
        link: String = anyMessage(),
        period: String = anyMessage()
    ) throws -> CodableSplashScreenSettings {
        
        let data = try sampleImageData()
        
        return .init(
            logo: logo ?? makeLogo(),
            text: text ?? makeText(),
            subtext: subtext,
            footer: footer ?? makeLogo(),
            imageData: imageData ?? .data(data),
            link: link,
            period: period
        )
    }
    
    private func sampleImageData(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let image = UIImage.make(withColor: .red)
        return try XCTUnwrap(image.pngData())
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
