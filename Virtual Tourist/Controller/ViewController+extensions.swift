//
//  ViewController+extensions.swift
//  Virtual Tourist
//
//  Created by Eyvind on 7/6/22.
//

import Foundation
import UIKit

extension UIViewController {
    func showSingleAlert(_ message: String, _ handler: @escaping ((_ action: UIAlertAction) -> Void) = {action in }) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alertVC, animated: true)
    }
}
