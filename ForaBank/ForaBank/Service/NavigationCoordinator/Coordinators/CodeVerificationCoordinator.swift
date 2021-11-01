//
//  CodeVerificationCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.10.2021.
//

import Foundation

class CodeVerificationCoordinator: Coordinator {

    let accountViewController = CodeVerificationViewController(model: CodeVerificationViewModel( type: CodeVerificationViewModel.CodeVerificationType.register))

    override init(router: RouterType) {
        super.init(router: router)
        router.setRootModule(accountViewController, hideBar: false)
    }
    
    override func start() {
    }
}
