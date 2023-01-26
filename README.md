<h1 align="center">Clean Architecture - CloudKit Client</h1> 
<p align="center">This is a study project with the main goal to implement <b>Clean Architecture</b>, based on Uncle Bob's teachings, in addiction to others featured concepts in Software Development community like: <b>YAGN</b> and <b>KISS</b>. The project was constructed using <b>TDD</b>, and has focus on validate the power of the architecture in unit tests cases in adiction to the use of <b>Fastlane</b> and Github actions as continuous integration tool. <b>CloudKit</b> is used as datasource.</p>

![Coverage](https://img.shields.io/codecov/c/github/ThiagoHBA/clean_arch_cloudkit_client/develop?style=for-the-badge) ![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white) ![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white) ![Fastlane](https://img.shields.io/badge/Fastlane-00F200.svg?style=for-the-badge&logo=Fastlane&logoColor=white) ![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white) 


## 📃 Summary
* [Features](#🛠️-features)
* [How to run](#💻-how-to-run-this-project)

## 🏗️ Features

- [x] List all tasks
- [x] Create task
- [ ] Update task
- [ ] Delete Task
- [ ] Create subtask

## 💻 How to run this project?
### Setup Steps

* Clone this code repository
* Open `cloudkit-client.xcodeproj`
* Update your Bundle Identifier in `General` tab on Xcode
* To use CloudKit you need to sign into a developer account
* Choose your account team in `Signing & Capabilities`
* Add a new library on top-right in Xcode and choose `iCloud` option
* Go to `cloudkit-client/Source/Data/Constant`
* Update the value of `containerIdentifier` variable to your iCloud Container name
* Launch a simulator and ensure that he was logged on an existent iCloud account

### Run unit tests

* Use `cmd+U` tool to execute unit tests on Xcode

## ⚒️ Technologies

*  Swift
*  UiKit


