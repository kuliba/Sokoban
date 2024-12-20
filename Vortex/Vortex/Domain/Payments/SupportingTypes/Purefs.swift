//
//  Purefs.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.06.2023.
//

enum Purefs {}
    
extension Purefs {
    
    // Transport Group
    static let transport          = "\(Config.puref)||1051062"
    
    // transport
    static let iVortexMosParking    = "\(Config.puref)||4990"
    static let iVortexPodorozhnik   = "\(Config.puref)||PYD"
    static let iVortexStrelka       = "\(Config.puref)||5300"
    static let iVortexTroika        = "\(Config.puref)||SB3"
    #if DEBUG || MOCK
    static let iVortexGibdd         = "\(Config.puref)||4811" // test
    #else
    static let iVortexGibdd         = "\(Config.puref)||5173" // live
    #endif
    
    // transport: Avtodor
    static let avtodorContract    = "\(Config.puref)||AVDD"
    static let avtodorTransponder = "\(Config.puref)||AVDТ"

    // transport: (fake) Avtodor Group for hardcoded
    static let avtodorGroup       = "AVD"
}

extension String {
    
    static let avtodorGroupTitle = "Автодор Платные дороги"
}
