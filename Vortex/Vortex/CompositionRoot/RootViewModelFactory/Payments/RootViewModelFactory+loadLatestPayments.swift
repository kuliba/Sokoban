//
//  RootViewModelFactory+loadLatestPayments.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.12.2024.
//

import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func loadLatestPayments(
        for latestPaymentsCategories: [String],
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        let getLatestPayments = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
        
        getLatestPayments(latestPaymentsCategories) {
            
            completion($0.map { $0.map { .init(origin: $0) } })
            _ = getLatestPayments
        }
    }
    
    @inlinable
    func loadLatestPayments(
        for latestPaymentsCategories: [String],
        completion: @escaping ([Latest]?) -> Void
    ) {
        loadLatestPayments(for: latestPaymentsCategories) {
            
            completion((try? $0.get()) ?? [])
        }
    }
    
    @inlinable
    func loadLatestPayments(
        for latestPaymentsCategory: String?,
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        loadLatestPayments(for: [latestPaymentsCategory].compactMap { $0 }, completion: completion)
    }
    
    @inlinable
    func loadLatestPayments(
        for category: ServiceCategory,
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        loadLatestPayments(for: category.latestPaymentsCategory, completion: completion)
    }
}
