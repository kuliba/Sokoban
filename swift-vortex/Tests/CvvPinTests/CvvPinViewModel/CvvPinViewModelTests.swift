//
//  CvvPinViewModelTests.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import Combine
import CvvPin
import XCTest

final class CvvPinViewModelTests: XCTestCase {
    
    func test_init_shouldSetStateToHidden() {
        
        let spy = makeSUT().spy
        
        XCTAssertNoDiff(spy.values, [.hidden])
    }
    
    func test_init_shouldNotRequestGetPin() {
        
        let pinLoader = makeSUT().pinLoader
        
        XCTAssertTrue(pinLoader.getPinCompletions.isEmpty)
    }
    
    func test_showPin_shouldSetStateToVisibleOnSuccessfulPinLoad() {
        
        let (sut, pinLoader, spy, scheduler) = makeSUT()
        
        sut.showPin()
        complete(pinLoader, withPin: "4321", on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .visible(.init(value: "4321"))
        ])
        scheduler.advance(by: .seconds(30))
    }
    
    func test_showPin_shouldSetStateToErrorOnPinLoadFailure() {
        
        let (sut, pinLoader, spy, scheduler) = makeSUT()
        
        sut.showPin()
        complete(pinLoader, with: anyNSError(), on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .error
        ])
    }
    
    func test_hidePin_shouldChangeStateFromVisibleToHidden() {
        
        let (sut, pinLoader, spy, scheduler) = makeSUT()
        sut.showPin()
        complete(pinLoader, withPin: "4321", on: scheduler)
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .visible(.init(value: "4321"))
        ])
        
        scheduler.advance(by: .seconds(5))
        hidePin(sut, on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .visible(.init(value: "4321")),
            .hidden
        ])
        
        scheduler.advance(by: .seconds(30))
        
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .visible(.init(value: "4321")),
            .hidden
        ])
    }
    
    func test_showPin_shouldSetStateToVisibleAndFlipToHiddenWithDelayOnSuccessfulPinLoad() {
        
        let (sut, pinLoader, spy, scheduler) = makeSUT()
        
        sut.showPin()
        complete(pinLoader, withPin: "4321", on: scheduler)
        
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .visible(.init(value: "4321"))
        ])
        
        scheduler.advance(by: .milliseconds(30 * 1_000 - 1))
        
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .visible(.init(value: "4321"))
        ])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [
            .hidden,
            .visible(.init(value: "4321")),
            .hidden
        ])
    }
    
    func test_showPin_shouldNotDeliverResultAfterInstanceHasBeenDeallocated() {
        
        let pinLoader = PinLoaderSpy()
        let timerSwitchModel = TimerSwitchModel()
        var sut: CvvPinViewModel? = .init(
            pinLoader: pinLoader,
            timerSwitchModel: timerSwitchModel
        )
        var receivedStates = [CvvPinViewModel.State]()
        let cancellable = sut?.$state
            .sink { receivedStates.append($0) }
        
        sut?.showPin()
        sut = nil
        pinLoader.complete(with: anyNSError())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(receivedStates, [.hidden])
        _ = cancellable
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: CvvPinViewModel,
        pinLoader: PinLoaderSpy,
        spy: ValueSpy<CvvPinViewModel.State>,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let pinLoader = PinLoaderSpy()
        let timeSwitch = TimerSwitchModel(
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let sut = CvvPinViewModel(
            pinLoader: pinLoader,
            timerSwitchModel: timeSwitch,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(pinLoader, file: file, line: line)
        trackForMemoryLeaks(timeSwitch, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, pinLoader, spy, scheduler)
    }
    
    private final class PinLoaderSpy: PinLoader {
        
        private(set) var getPinCompletions = [GetPinCompletion]()
        
        func getPin(completion: @escaping GetPinCompletion) {
            
            getPinCompletions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            
            getPinCompletions[index](.failure(error))
        }
        
        func completeSuccessfully(withPin pin: String, at index: Int = 0) {
            
            getPinCompletions[index](.success(pin))
        }
    }
    
    private func complete(
        _ pinLoader: PinLoaderSpy,
        withPin pin: String,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        pinLoader.completeSuccessfully(withPin: pin)
        scheduler.advance()
    }
    
    private func complete(
        _ pinLoader: PinLoaderSpy,
        with error: Error,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        pinLoader.complete(with: error)
        scheduler.advance()
    }
    
    private func hidePin(
        _ sut: CvvPinViewModel,
        on scheduler: TestSchedulerOfDispatchQueue
    ) {
        sut.hidePin()
        scheduler.advance()
    }
}
