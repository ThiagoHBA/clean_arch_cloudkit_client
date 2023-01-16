//
//  EmptyTaskNameError.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 10/01/23.
//

import Foundation

struct EmptyTaskNameError: UseCaseError {
    var taskErrorDescription: String = "Não é possível criar uma taréfa com nome vazio."
    var recoverySuggestion: String? = "Dê um nome para a atividade"
}
