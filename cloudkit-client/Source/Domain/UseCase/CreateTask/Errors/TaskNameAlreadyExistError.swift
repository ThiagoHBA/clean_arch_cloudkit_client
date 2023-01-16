//
//  TaskNameAlreadyExistError.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 10/01/23.
//

import Foundation

struct TaskNameAlreadyExistError: UseCaseError {
    var taskErrorDescription: String = "Uma taréfa com o mesmo nome já foi criada."
    var recoverySuggestion: String? = "Modifique o nome e tente novamente"
}
