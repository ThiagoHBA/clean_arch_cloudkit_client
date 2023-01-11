//
//  TaskListPresenter.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation

class TaskListPresenter: TaskListPresenting {
    let listTaskUseCase: ListTasksUseCase
    let createTaskUseCase: CreateTaskUseCase
    var view: TaskListViewProtocol? // Retain Cicle
    
    init(
        listTaskUseCase: ListTasksUseCase,
        createTaskUseCase: CreateTaskUseCase
    ) {
        self.listTaskUseCase = listTaskUseCase
        self.createTaskUseCase = createTaskUseCase
    }
    
    func initState() {
        view?.showLoading() {}
        listTaskUseCase.execute()
    }

    func createTask(_ task: Task) {
        view?.showLoading () {}
        createTaskUseCase.input = task
        createTaskUseCase.execute()
    }
}

extension TaskListPresenter: ListTasksUseCaseOutput {
    func tasksAreFetched(tasks: [Task]) {
        view?.hideLoading() {}
        view?.displayTaskList(tasks) {}
    }
    
    func errorWhileFetchingTasks(error: Error) {
        view?.hideLoading() {}
        view?.displayError(title: "Erro ao listar taféfas!", message: error.localizedDescription) {}
    }
}

extension TaskListPresenter: CreateTaskUseCaseOutput {
    func errorWhileCreatingTask(_ error: Error) {
        view?.hideLoading() {}
        view?.displayError(title: "Erro ao criar taréfa!", message: error.localizedDescription) {}
    }
    
    func succesfullyCreateTask(_ task: Task) {
        view?.hideLoading() {}
        view?.includeTask(task) {}
    }
}
