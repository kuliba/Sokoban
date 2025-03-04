//
//  GetShowcaseDomain.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

public enum GetShowcaseDomain {

    public typealias ShowCase = CollateralLoanLandingGetShowcaseData
    public typealias Result<InformerPayload> = Swift.Result<ShowCase, BackendFailure<InformerPayload>>
}
