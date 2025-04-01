//
//  RootViewModelFactory+makeSplashScreenBinder.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import Combine
import RxViewModel
import SplashScreenCore
import SplashScreenUI
import SwiftUI

/// This is not a typical `Binder` - `flow` is not intended to be used, but to prevent deallocation.
typealias SplashScreenBinder = Binder<SplashScreenViewModel, SplashEventsHandler>

extension RootViewModelFactory {
    
    @inlinable
    func makeSplashScreenBinder(
        flag: SplashScreenFlag,
        fadeout: Delay = .milliseconds(300)
    ) -> SplashScreenBinder {
        
        let splash = makeSplashScreenViewModel(
            phase: flag.isActive ? .cover : .hidden
        )
        let handler = SplashEventsHandler(
            authOKPublisher: model.pinOrSensorAuthOK.eraseToAnyPublisher(),
            startPublisher: model.hideCoverStartSplash.eraseToAnyPublisher(),
            event: feedbackDecoratedEvent(splash: splash)
        )
        
        let delay: Delay = .seconds(splash.state.settings.duration) - fadeout
        
        let cancellables = flag.isActive ? handler.bind(delay: delay, on: schedulers.background) : []
        
        return .init(content: splash, flow: handler) { _,_ in cancellables }
    }
    
    @inlinable
    func feedbackDecoratedEvent(
        splash: SplashScreenViewModel
    ) -> (SplashScreenEvent) -> Void {
        
        return { [weak self, weak splash] event in
            
            splash?.event(event)
            if event == .hide { self?.generateFeedback(style: .light) }
        }
    }
    
    @inlinable
    func generateFeedback(
        style: UIImpactFeedbackGenerator.FeedbackStyle = .light
    ) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    @inlinable
    func makeSplashScreenViewModel(
        phase: SplashScreenState.Phase
    ) -> SplashScreenViewModel {
        
        let settings = composeSplashScreenSettings()
        let initialState = SplashScreenState(phase: phase, settings: settings)
        
        let reducer = SplashScreenReducer()
        let effectHandler = SplashScreenEffectHandler { [weak self] completion in
            
            self?.schedulers.background.delay(for: .seconds(30)) { [weak self] in
                
                completion(self?.loadSplashScreenSettings())
            }
        }
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func composeSplashScreenSettings() -> SplashScreenState.Settings {
        
        return loadSplashScreenSettings() ?? composeDefaultSplashScreenSettings()
    }
    
    @inlinable
    func loadSplashScreenSettings() -> SplashScreenState.Settings? {
        
        guard let storage = loadSplashImagesCache(),
              let settings = composeSplashScreenSettings(storage: storage)
        else { return nil }
        
        return settings
    }
    
    @inlinable
    func composeSplashScreenSettings(
        storage: SplashScreenStorage?
    ) -> SplashScreenState.Settings? {
        
        let timePeriod = getTimePeriodString()
        
        guard let items = storage?.items(for: timePeriod.timePeriod),
              let random = items.settings.randomElement()
        else { return nil }
        
        let userName = getUserName()
        
        return random.insert(userName: userName)
    }
    
    
    @inlinable
    func composeDefaultSplashScreenSettings() -> SplashScreenState.Settings {
        
        let timePeriod = getTimePeriodString()
        let userName = getUserName()
        
        return .default(for: timePeriod).insert(userName: userName)
    }
    
    @inlinable
    func getUserName() -> String? {
        
        guard let info = model.localAgent.load(type: ClientInfoData.self)
        else { return nil }
        
        return info.customName ?? info.firstName
    }
}

// MARK: - Adapters

extension SplashScreenState.Settings {
    
    func insert(userName: String?) -> Self {
        
        guard text.value.contains("_") else { return self }
        
        return .init(
            duration: duration,
            image: image,
            logo: logo,
            text: .init(
                color: text.color,
                size: text.size,
                value: text.value.replacingUnderscores(with: userName),
                shadow: text.shadow
            ),
            subtext: subtext,
            footer: footer
        )
    }
}

private extension String {
    
    func replacingUnderscores(with replacement: String?) -> String {
        
        if let replacement  {
            return replacingOccurrences(of: "_", with: replacement)
        } else {
            return replacingOccurrences(of: ",\n_!", with: "!")
        }
    }
}

private extension Array where Element == SplashScreenSettings {
    
    var settings: [SplashScreenState.Settings] {
        
        compactMap {
            
            guard case let .success(data) = $0.imageData,
                  let image = Image(data: data)
            else { return nil }
            
            return .init(
                duration: $0.duration,
                image: image,
                logo: $0._logo,
                text: $0._text,
                subtext: $0._subtext,
                footer: $0._footer
            )
        }
    }
}

private extension SplashScreenSettings {
    
    var _logo: SplashScreenState.Settings.Logo {
        
        return .init(color: .init(hex: logo.color), shadow: logo.shadow._shadow)
    }
    
    var _text: SplashScreenState.Settings.Text {
        
        return .init(
            color: .init(hex: text.color),
            size: text.size,
            value: text.value,
            shadow: text.shadow._shadow
        )
    }
    
    var _subtext: SplashScreenState.Settings.Text? {
        
        guard let subtext else { return nil }
        
        return .init(
            color: .init(hex: subtext.color),
            size: subtext.size,
            value: subtext.value,
            shadow: subtext.shadow._shadow
        )
    }
    
    var _footer: SplashScreenState.Settings.Logo {
        
        return .init(
            color: .init(hex: footer.color),
            shadow: footer.shadow._shadow
        )
    }
}

private extension SplashScreenSettings.Shadow {
    
    var _shadow: SplashScreenState.Settings.Shadow {
        
        return .init(color: .init(hex: color), opacity: opacity, radius: radius, x: x, y: y)
    }
}

// MARK: - Defaults

private extension SplashScreenState.Settings {
    
    static func `default`(
        for timePeriod: SplashScreenTimePeriod
    ) -> Self {
        
        return .init(
            duration: 2.0,
            image: .init("splash"),
            logo: .logo,
            text: .default(for: timePeriod),
            subtext: nil,
            footer: .footer
        )
    }
}

private extension SplashScreenState.Settings.Logo {
    
    static let logo:   Self = .init(color: .init(hex: "FFFFFF"), shadow: .logo)
    static let footer: Self = .init(color: .init(hex: "FFFFFF"), shadow: .footer)
}

private extension SplashScreenState.Settings.Text {
    
    static func `default`(
        for timePeriod: SplashScreenTimePeriod
    ) -> Self {
        
        let value = timePeriod.timePeriod.timePeriodGreeting
        
        return .init(color: .init(hex: "FFFFFF"), size: 24, value: value, shadow: .text)
    }
}

private extension String {
    
    var timePeriodGreeting: String {
        
        switch self {
        case "MORNING": return "Доброе утро,\n_!"
        case "EVENING": return "Добрый вечер,\n_!"
        case "NIGHT":   return "Доброй ночи,\n_!"
        default:        return "Добрый день,\n_!"
        }
    }
}

private extension SplashScreenState.Settings.Shadow {
    
    static let logo:   Self = .init(color: .init(hex: "000000"), opacity: 0.25, radius: 64, x: 0, y: 4)
    static let text:   Self = .init(color: .init(hex: "000000"), opacity: 0.25, radius: 12, x: 0, y: 4)
    static let footer: Self = .init(color: .init(hex: "000000"), opacity: 0.25, radius:  4, x: 0, y: 4)
}
