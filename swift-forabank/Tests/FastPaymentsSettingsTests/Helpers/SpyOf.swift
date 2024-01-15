//
//  SpyOf.swift
//  FastPaymentsSettingsPreviewTests
//
//  Created by Igor Malyarov on 15.01.2024.
//

typealias SpyOf<Payload, Success, Failure: Error> = Spy<Payload, Result<Success, Failure>>
