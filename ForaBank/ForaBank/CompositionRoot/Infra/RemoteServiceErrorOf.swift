//
//  RemoteServiceErrorOf.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.02.2024.
//

import GenericRemoteService

typealias RemoteServiceErrorOf<MappingError: Error> = RemoteServiceError<Error, Error, MappingError>
