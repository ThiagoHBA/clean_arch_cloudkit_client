//
//  WeakReferenceObject.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 14/01/23.
//

import Foundation

final class WeakReference<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakReference: TaskListViewProtocol where T: TaskListViewProtocol {
    func includeTask(_ task: Task, completion: @escaping () -> Void) {
        assert(object != nil)
        object?.includeTask(task, completion: completion)
    }
    
    func displayTaskList(_ tasks: [Task], completion: @escaping () -> Void) {
        assert(object != nil)
        object!.displayTaskList(tasks, completion: completion)
    }
    
    func displayError(title: String, message: String, completion: @escaping () -> Void) {
        assert(object != nil)
        object!.displayError(title: title, message: message, completion: completion)
    }
    
    func showLoading(completion: @escaping () -> Void) {
        assert(object != nil)
        object!.showLoading(completion: completion)
    }
    
    func hideLoading(completion: @escaping () -> Void) {
        assert(object != nil)
        object!.hideLoading(completion: completion)
    }
}
