//
//  AddSubtaskUseCase.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

class AddSubtaskUseCase {
    var repository: TaskRepositoryProtocol
    
     init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() { }
}
