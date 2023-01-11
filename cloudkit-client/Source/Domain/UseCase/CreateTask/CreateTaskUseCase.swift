//
//  CreateTaskUseCase.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 10/01/23.
//

import Foundation

class CreateTaskUseCase: UseCase {
    var repository: TaskRepositoryProtocol
    var output: CreateTaskUseCaseOutput?
    var input: Task?
    
    required init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
        
    func execute() {
        guard let inputTask = input else { return }
        if inputTask.name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            output?.errorWhileCreatingTask(EmptyTaskNameError())
            return
        }
        repository.findTask(inputTask) { [weak self] findedTask in
            if findedTask != nil {
                self?.output?.errorWhileCreatingTask(TaskNameAlreadyExistError())
                return
            }
            self?.output?.succesfullyCreateTask(inputTask)
        }
    }
    
}
