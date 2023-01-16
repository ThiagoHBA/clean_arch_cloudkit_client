import Foundation

class ListTasksUseCase: UseCase {
    var repository: TaskRepositoryProtocol
    var output: ListTasksUseCaseOutput?
    var input: Any? = nil
    
    required init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
     
    func execute() {
        repository.fetchAllTasks { [weak self] result in
            switch result {
                case .success(let tasks):
                    self?.output?.tasksAreFetched(tasks: tasks)
                case .failure(let error):
                    self?.output?.errorWhileFetchingTasks(error: error)
            }
        }
    }
}
