//
//  RemoteDomainOf.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.09.2024.
//

import RemoteServices

typealias RemoteDomainOf<Payload, Response, Failure: Error> = RemoteDomain<Payload, Response, RemoteServices.ResponseMapper.MappingError, Failure>
