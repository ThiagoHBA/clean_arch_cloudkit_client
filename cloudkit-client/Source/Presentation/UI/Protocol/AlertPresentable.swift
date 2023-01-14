//
//  AlertPresentable.swift
//  cloudkit-client
//
//  Created by Thiago Henrique on 14/01/23.
//

import Foundation
import UIKit

protocol AlertPresentable { }

extension AlertPresentable where Self: UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    func showTextFieldAlert(
        _ alert: UIAlertController,
        completion: (() -> Void)? = nil,
        action: @escaping (String) -> Void
    ) {
        alert.addTextField { (textField) in
            textField.placeholder = "Escreva aqui"
        }
        
        alert.addAction(
            UIAlertAction(
                title: "Cancelar",
                style: .cancel,
                handler: nil
            )
        )

        let saveAction = UIAlertAction (
            title: "OK",
            style: .default,
            handler: { [weak alert] (_) in
                action(alert?.textFields![0].text ?? "")
            })
        
        alert.addAction(saveAction)
        saveAction.isEnabled = false

        NotificationCenter.default.addObserver (
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields![0],
            queue: OperationQueue.main
        ) { (notification) in
            saveAction.isEnabled = alert.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }

        present(alert, animated: true, completion: completion)
    }
}
