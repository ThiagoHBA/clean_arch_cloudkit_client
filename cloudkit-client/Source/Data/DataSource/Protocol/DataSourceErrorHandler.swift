//
//  DataSourceErrorHandler.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 02/01/23.
//

import Foundation

protocol DataSourceErrorHandler {
    func handleError(_ error: Error) -> Error
}
