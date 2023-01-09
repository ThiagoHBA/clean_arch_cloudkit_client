//
//  RepositoryErrorStub.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 09/01/23.
//

import Foundation

enum RepositoryErrorStub: Error, LocalizedError {
    case mockedError
    
    var errorDescription: String? {
        return "Localized description"
    }
}
