//
//  MappingRemoteServiceError.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2023.
//

import GenericRemoteService

typealias MappingRemoteServiceError<MapResponseError: Error> = RemoteServiceError<Error, Error, MapResponseError>
