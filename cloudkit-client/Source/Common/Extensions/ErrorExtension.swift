//
//  ErrorExtension.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 02/01/23.
//

import Foundation

extension LocalizedError where Self: CustomStringConvertible {
   var errorDescription: String? { return description }
}
