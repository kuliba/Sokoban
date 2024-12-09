//
//  ImageLoader.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.06.2024.
//

import VortexTools
import SwiftUI

typealias ImageLoader = VortexTools.Loader<String, Result<(String, Image), Error>>
