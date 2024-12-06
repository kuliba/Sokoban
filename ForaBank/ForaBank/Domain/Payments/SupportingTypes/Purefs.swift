//
//  Purefs.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.06.2023.
//

enum Purefs {}
    
extension Purefs {
    
    // Transport Group
    static let transport          = "iFora||1051062"
    
    // transport
    static let iForaMosParking    = "iFora||4990"
    static let iForaPodorozhnik   = "iFora||PYD"
    static let iForaStrelka       = "iFora||5300"
    static let iForaTroika        = "iFora||SB3"
    #if DEBUG || MOCK
    static let iForaGibdd         = "iFora||4811" // test
    #else
    static let iForaGibdd         = "iFora||5173" // live
    #endif
    
    // transport: Avtodor
    static let avtodorContract    = "iFora||AVDD"
    static let avtodorTransponder = "iFora||AVDТ"

    // transport: (fake) Avtodor Group for hardcoded
    static let avtodorGroup       = "AVD"
}

extension String {
    
    static let avtodorGroupTitle = "Автодор Платные дороги"
}
