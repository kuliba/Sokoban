//
//  RootViewModelFactory+makeSplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreenCore
import SplashScreenUI
import SwiftUI

extension RootViewModelFactory {
    
    @inlinable
    func makeSplashScreenViewModel(
        flag: SplashScreenFlag
    ) -> SplashScreenViewModel {
        
        let userName = getUserName()
        let composed = composeSplashScreenSettings().insert(userName: userName)
        
        let initialState = SplashScreenState(
            phase: flag.isActive ? .cover : .hidden,
            settings: composed
        )
        let reducer = SplashScreenReducer()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: { _,_ in },
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func getUserName() -> String? {
        
        guard let info = model.localAgent.load(type: ClientInfoData.self)
        else { return nil }
        
        return info.customName ?? info.firstName
    }
    
    @inlinable
    func composeSplashScreenSettings() -> SplashScreenState.Settings {
        
        let timePeriod = getTimePeriodString()
        let cache = loadSplashImagesCache()
        
        guard let items = cache?.items(for: timePeriod.timePeriod)?.settings,
              let random = items.randomElement()
        else { return .default(for: timePeriod) }
        
        return random
    }
}

// MARK: - Adapters

extension SplashScreenState.Settings {
    
    func insert(userName: String?) -> Self {
        
        guard text.value.contains("_") else { return self }
        
        return .init(
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
