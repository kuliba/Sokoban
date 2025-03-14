//
//  RootViewModelFactory+makeSplashScreenViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 14.03.2025.
//

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
        
        let sut = try makeSUT(calendar: calendarTokyo(), hour: 10, minute: 15)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Tokyo() throws {
        
        let sut = try makeSUT(calendar: calendarTokyo(), hour: 13, minute: 33)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Tokyo() throws {
        
        let sut = try makeSUT(calendar: calendarTokyo(), hour: 19, minute: 45)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Tokyo() throws {
        
        let sut = try makeSUT(calendar: calendarTokyo(), hour: 1, minute: 20)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    func test_shouldSetSplashTextToMorning_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: calendarParis(), hour: 10, minute: 5)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: calendarParis(), hour: 13, minute: 45)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: calendarParis(), hour: 19, minute: 33)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Paris() throws {
        
        let sut = try makeSUT(calendar: calendarParis(), hour: 1, minute: 33)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    // MARK: - Text without user name
    
    func test_shouldSetSplashTextWithCustomName_onActiveFlag_Paris() throws {
        
        let (firstName, customName) = (anyMessage(), anyMessage())
        let model = try withClientInfo(firstName: firstName, customName: customName)
        let sut = try makeSUT(calendar: calendarParis(), hour: 10, minute: 20, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(customName)!")
    }
    
    func test_shouldSetSplashTextWithCustomName_onActiveFlag_Tokyo() throws {
        
        let (firstName, customName) = (anyMessage(), anyMessage())
        let model = try withClientInfo(firstName: firstName, customName: customName)
        let sut = try makeSUT(calendar: calendarTokyo(), hour: 2, minute: 15, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи,\n\(customName)!")
    }
    
    func test_shouldSetSplashTextWithFirstName_onNilCustomName_onActiveFlag_Paris() throws {
        
        let firstName = anyMessage()
        let model = try withClientInfo(firstName: firstName, customName: nil)
        let sut = try makeSUT(calendar: calendarParis(), hour: 10, minute: 20, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(firstName)!")
    }

    func test_shouldSetSplashTextWithFirstName_onNilCustomName_onActiveFlag_Tokyo() throws {
        
        let firstName = anyMessage()
        let model = try withClientInfo(firstName: firstName, customName: nil)
        let sut = try makeSUT(calendar: calendarTokyo(), hour: 20, minute: 45, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер,\n\(firstName)!")
    }

    // MARK: - Helpers Tests
    
    func test_makeTime() throws {
        
        let calendar = calendarTokyo()
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        let timeString = calendar.currentTimeString { date }
        
        XCTAssertNoDiff(timeString, "10:20")
    }
    
    // MARK: - Helpers
    
    private func withClientInfo(
        firstName: String,
        customName: String? = nil
    ) throws -> Model {
        
        let info = makeClientInfoData(firstName: firstName, customName: customName)
        let localAgent = try LocalAgentStub(value: info)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)

        return model
    }
    
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
    
    func calendarTokyo(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Calendar {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try! XCTUnwrap(.init(identifier: "Asia/Tokyo"), "Expected TimeZone, but got nil instead.", file: file, line: line)
        
        return calendar
    }
    
    func calendarParis(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Calendar {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try! XCTUnwrap(.init(identifier: "Europe/Paris"), "Expected TimeZone, but got nil instead.", file: file, line: line)
        
        return calendar
    }
}
