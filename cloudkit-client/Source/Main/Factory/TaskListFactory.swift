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
        presenter.view = vc
        
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
