//
// Created by Vlad Zhavoronkov on 11/9/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(withTitle title: String?, andContent content: String?) {
        let ac = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        ac.addAction(okAction)
        present(ac, animated: true)
    }

    func presentAlert(error: Error) {
        presentAlert(withTitle: "Error 🤚",
            andContent: "\(error)")
    }
}