//
//  TaskListPresenter.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

class TaskListPresenter: TaskListPresenting {
    let listTaskUseCase: ListTasksUseCase
    var view: TaskListViewProtocol? // Retain Cicle
    
    init(listTaskUseCase: ListTasksUseCase) {
        self.listTaskUseCase = listTaskUseCase
    }
    
    func initState() {
        view?.showLoading()
        listTaskUseCase.execute()
    }
}

extension TaskListPresenter: ListTasksUseCaseOutput {
    func tasksAreFetched(tasks: [Task]) {
        view?.hideLoading()
        view?.displayTaskList(tasks)
    }
    
    func errorWhileFetchingTasks(error: Error) {
        view?.hideLoading()
        view?.displayError(title: "Erro!", message: error.localizedDescription)
    }
}
