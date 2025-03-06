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
              let serial = data.serial else { throw ResponseFailure() }
        
        self.init(
            list: splashSettings.map(ResponseMapper.SplashScreenSettings.init),
            serial: serial
        )
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper.SplashScreenSettings {
    
    init(_ data: ResponseMapper._Data._SplashSettings) {
        
        self.init(
            link: data.link,
            viewDuration: data.viewDuration,
            hasAnimation: data.hasAnimation ?? false,
            bankLogo: data.bankLogo.flatMap(ResponseMapper.Logo.init),
            text: data.text.flatMap(ResponseMapper.Text.init),
            background: data.background.flatMap(ResponseMapper.Background.init),
            subtext: data.subtext.flatMap(ResponseMapper.Text.init),
            bankName: data.bankName.flatMap(ResponseMapper.Logo.init)
        )
    }
}

private extension ResponseMapper.Logo {
    
    init(_ data: ResponseMapper._Data._Logo) {
        
        self.init(
            color: data.color,
            shadow: data.shadow.flatMap(ResponseMapper.Shadow.init)
        )
    }
}

private extension ResponseMapper.Text {
    
    init(_ data: ResponseMapper._Data._Text) {
        
        self.init(
            color: data.color,
            size: data.size,
            value: data.value,
            shadow: data.shadow.flatMap(ResponseMapper.Shadow.init)
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

private extension ResponseMapper.Shadow {
    
    init?(_ data: ResponseMapper._Data._Shadow) {
        
        self.init(
            x: data.x,
            y: data.y,
            blur: data.blur,
            color: data.color,
            opacity: data.opacity
        )
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
