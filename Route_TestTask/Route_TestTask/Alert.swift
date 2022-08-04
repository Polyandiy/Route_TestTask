//
//  Alert.swift
//  Route_TestTask
//
//  Created by Поляндий on 01.08.2022.
//

import UIKit
import MapKit

extension ViewController {
    
    func alertAddAddress(title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let alertOK = UIAlertAction(title: "Ок", style: .default) {(action) in
            let textField = alertController.textFields?.first
            guard let text = textField?.text else { return }
            completionHandler(text)
        }
        
        let alertCancel = UIAlertAction(title: "Отменить", style: .default) {(_) in
        }
        
        alertController.addAction(alertOK)
        alertController.addAction(alertCancel)
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func errorAlert (title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(alertOK)
        
        present(alertController, animated: true, completion: nil)
    }
}
