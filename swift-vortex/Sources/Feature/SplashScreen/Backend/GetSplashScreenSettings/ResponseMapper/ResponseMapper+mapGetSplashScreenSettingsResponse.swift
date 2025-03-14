//
//  ResponseMapper+mapGetSplashScreenSettingsResponse.swift
//
//
//  Created by Nikolay Pochekuev on 19.02.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetSplashScreenSettingsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetSplashScreenSettingsResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetSplashScreenSettingsResponse.init)
    }
}

private extension ResponseMapper.GetSplashScreenSettingsResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        guard let splashSettings = data.splash,
              let serial = data.serial
        else { throw ResponseFailure() }
        
        self.init(
            list: splashSettings.compactMap(\.settings),
            serial: serial
        )
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper._Data._SplashSettings {
    
    var settings: ResponseMapper.SplashScreenSettings? {
        
        guard let link,
              let bankLogo = bankLogo?.logo,
              let text = text?.text,
              let bankName = bankName?.logo
        else { return nil }
        
        return .init(
            link: link,
            viewDuration: viewDuration,
            hasAnimation: hasAnimation ?? false,
            bankLogo: bankLogo,
            text: text,
            background: background.flatMap(ResponseMapper.Background.init),
            subtext: subtext?.text,
            bankName: bankName
        )
    }
}

private extension ResponseMapper._Data._Logo {
    
    var logo: ResponseMapper.Logo? {
        
        guard let color, let shadow = shadow?.shadow
        else { return nil }
        
        return .init(color: color, shadow: shadow)
    }
}

private extension ResponseMapper._Data._Text {
    
    var text: ResponseMapper.Text? {
        
        guard let color, let size, let value, let shadow = shadow?.shadow
        else { return nil }
        
        return .init(
            color: color,
            size: size,
            value: value,
            shadow: shadow
        )
    }
}

private extension ResponseMapper.Background {
    
    init(_ data: ResponseMapper._Data._Background) {
        
        self.init(
            hasBackground: data.hasBackground ?? false,
            color: data.color,
            opacity: data.opacity
        )
    }
}

private extension ResponseMapper._Data._Shadow {
    
    var shadow: ResponseMapper.Shadow? {
        
        guard let x, let y, let blur, let color, let opacity
        else { return nil }
        
        return .init(x: x, y: y, blur: blur, color: color, opacity: opacity)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let serial: String?
        let splash: [_SplashSettings]?
        
        struct _SplashSettings: Decodable {
            
            let link: String?
            let viewDuration: Int?
            let hasAnimation: Bool?
            let bankLogo: _Logo?
            let text: _Text?
            let background: _Background?
            let subtext: _Text?
            let bankName: _Logo?
        }
        
        struct _Logo: Decodable {
            
            let color: String?
            let shadow: _Shadow?
        }
        
        struct _Text: Decodable {
            
            let color: String?
            let size: Int?
            let value: String?
            let shadow: _Shadow?
        }
        
        struct _Background: Decodable {
            
            let hasBackground: Bool?
            let color: String?
            let opacity: Int?
        }
        
        struct _Shadow: Decodable {
            
            let x: Int?
            let y: Int?
            let blur: Int?
            let color: String?
            let opacity: Int?
        }
    }
}
