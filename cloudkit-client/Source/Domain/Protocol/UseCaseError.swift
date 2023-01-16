//
//  UseCaseError.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 10/01/23.
//

import Foundation

protocol UseCaseError: LocalizedError, CustomStringConvertible {
    var taskErrorDescription: String { get set }
    var recoverySuggestion: String? { get set }
    var description: String { get }
}

extension UseCaseError {
    var description: String { return
        "\(taskErrorDescription) \(recoverySuggestion ?? "")"
    }
}
