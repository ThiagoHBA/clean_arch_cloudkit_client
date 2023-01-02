//
//  TaskListSwiftUi.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 29/12/22.
//

import SwiftUI

class ViewModel: ObservableObject {
    let presenter: TaskListPresenting
    @Published var label = ""
    
    init(presenter: TaskListPresenting) {
        self.presenter = presenter
    }
}

struct TaskListSwiftUi: View {
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        Text(vm.label)
            .onAppear {
                vm.presenter.initState()
            }
    }
}

extension TaskListSwiftUi: TaskListViewProtocol {
    func showLoading() {
        vm.label = "Start Loading"
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            vm.label = "Finish Loading"
        }
    }
    
    func displayTaskList(_ tasks: [Task]) {
        DispatchQueue.main.async { 
            vm.label = "Displaying tasks..."
        }
    }
    
    func displayError(title: String, message: String) {
        DispatchQueue.main.async {
            vm.label = "Error: \(title) - \(message)"
        }
    }
}



