//
//  Coordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.09.2021.
//

import UIKit

public protocol BaseCoordinatorType: AnyObject {
    associatedtype DeepLinkType
    func start()
    func start(with link: DeepLinkType?)
}

public protocol PresentableCoordinatorType: BaseCoordinatorType, Presentable {}

open class PresentableCoordinator<DeepLinkType>: NSObject, PresentableCoordinatorType {
    
    public override init() {
        super.init()
    }
    
    open func start() { start(with: nil) }
    open func start(with link: DeepLinkType?) {}

    open func toPresentable() -> UIViewController {
        fatalError("Must override toPresentable()")
    }
}


public protocol CoordinatorType: PresentableCoordinatorType {
    var router: RouterType { get }
}


open class Coordinator<DeepLinkType>: PresentableCoordinator<DeepLinkType>, CoordinatorType  {
    
    public var childCoordinators: [Coordinator<DeepLinkType>] = []
    
    open var router: RouterType
    
    public init(router: RouterType) {
        self.router = router
        super.init()
    }
    
    public func addChild(_ coordinator: Coordinator<DeepLinkType>) {
        childCoordinators.append(coordinator)
    }
    
    public func removeChild(_ coordinator: Coordinator<DeepLinkType>?) {
        
        if let coordinator = coordinator, let index = childCoordinators.firstIndex(of: coordinator) {
            childCoordinators.remove(at: index)
        }
    }
    
    open override func toPresentable() -> UIViewController {
        return router.toPresentable()
    }
}

enum DeepLink {
    case auth
    case home
}
