//
//  TaskListFactory.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 28/12/22.
//

import Foundation
import UIKit
import SwiftUI

struct TaskListViewControllerFactory {
    
    static func make() -> UIViewController {
        let taskRepository = TaskRepository(
            taskDAO: TaskDAO(client: CloudKitClient()),
            errorHandler: CloudKitErrorHandler(),
            mapper: TaskMapper(client: CloudKitClient())
        )
        
        let listTaskUseCase = ListTasksUseCase(repository: taskRepository)
        let presenter = TaskListPresenter(listTaskUseCase: listTaskUseCase)
        listTaskUseCase.output = presenter
        
        let vc = TaskListViewController(presenter: presenter)
        presenter.view = WeakReference(vc)
        
        return vc
    }
    
    static func makeSwiftUI() -> UIViewController {
        let taskRepository = TaskRepository(
            taskDAO: TaskDAO(client: CloudKitClient()),
            errorHandler: CloudKitErrorHandler(),
            mapper: TaskMapper(client: CloudKitClient())
        )
        
        let listTaskUseCase = ListTasksUseCase(repository: taskRepository)
        let presenter = TaskListPresenter(listTaskUseCase: listTaskUseCase)
        listTaskUseCase.output = presenter
        
        let vc = TaskListSwiftUi(vm: ViewModel(presenter: presenter))
        presenter.view = vc 
        
        return UIHostingController (rootView: vc)
    }
}

final class WeakReference<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakReference: TaskListViewProtocol where T: TaskListViewProtocol {
    func displayTaskList(_ tasks: [Task]) {
        assert(object != nil)
        object!.displayTaskList(tasks)
    }
    
    func displayError(title: String, message: String) {
        assert(object != nil)
        object!.displayError(title: title, message: message)
    }
    
    func showLoading() {
        assert(object != nil)
        object!.showLoading()
    }
    
    func hideLoading() {
        assert(object != nil)
        object!.hideLoading()
    }
}
