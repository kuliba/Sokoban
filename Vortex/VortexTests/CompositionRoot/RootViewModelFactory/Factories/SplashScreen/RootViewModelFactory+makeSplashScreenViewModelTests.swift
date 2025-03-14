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
        
        let calendar = calendarTokyo()
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Tokyo() throws {
        
        let calendar = calendarTokyo()
        let date = try makeTime(hour: 13, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Tokyo() throws {
        
        let calendar = calendarTokyo()
        let date = try makeTime(hour: 19, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Tokyo() throws {
        
        let calendar = calendarTokyo()
        let date = try makeTime(hour: 01, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    func test_shouldSetSplashTextToMorning_onActiveFlag_Paris() throws {
        
        let calendar = calendarParis()
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро!")
    }
    
    func test_shouldSetSplashTextToDay_onActiveFlag_Paris() throws {
        
        let calendar = calendarParis()
        let date = try makeTime(hour: 13, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый день!")
    }
    
    func test_shouldSetSplashTextToEvening_onActiveFlag_Paris() throws {
        
        let calendar = calendarParis()
        let date = try makeTime(hour: 19, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Добрый вечер!")
    }
    
    func test_shouldSetSplashTextToNight_onActiveFlag_Paris() throws {
        
        let calendar = calendarParis()
        let date = try makeTime(hour: 01, minute: 20, calendar: calendar)
        
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date })
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброй ночи!")
    }
    
    // MARK: - Text without user name
    
    func test_shouldSetSplashTextWithCustomName_onActiveFlag_Paris() throws {
        
        let (firstName, customName) = (anyMessage(), anyMessage())
        let calendar = calendarParis()
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        
        let info = makeClientInfoData(firstName: firstName, customName: customName)
        let localAgent = try LocalAgentStub(value: info)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date }, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(customName)!")
    }
    
    func test_shouldSetSplashTextWithFirstName_onNilCustomName_onActiveFlag_Paris() throws {
        
        let firstName = anyMessage()
        let calendar = calendarParis()
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        
        let info = makeClientInfoData(firstName: firstName, customName: nil)
        let localAgent = try LocalAgentStub(value: info)
        let model: Model = .mockWithEmptyExcept(localAgent: localAgent)
        let (sut, _,_) = makeSUT(calendar: calendar, currentDate: { date }, model: model)
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.settings.text.value, "Доброе утро,\n\(firstName)!")
    }

    // MARK: - Helpers Tests
    
    func test_makeTime() throws {
        
        let calendar = calendarTokyo()
        let date = try makeTime(hour: 10, minute: 20, calendar: calendar)
        let timeString = calendar.currentTimeString { date }
        
        XCTAssertNoDiff(timeString, "10:20")
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
