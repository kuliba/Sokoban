//
//  main.swift
//  Vortex
//
//  Created by Max Gribov on 04.02.2022.
//

import UIKit

let appDelegateClass: AnyClass = NSClassFromString("TestingAppDelegate") ?? AppDelegate.self

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(ForaApplication.self), NSStringFromClass(appDelegateClass))
