//
//  LoadFormResult.swift
//  
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import LoadableState

public typealias LoadFormResult<Confirmation> = Result<Form<Confirmation>, LoadFailure>
