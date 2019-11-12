//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

class ImageDisplayModeAnimationController:
    NSObject, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    let animator = ImageDisplayModeAnimator()

    weak var source: ImageDisplayModeAnimatorDelegate?
    weak var destination: ImageDisplayModeAnimatorDelegate?

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        (animator.destination, animator.source) = (destination, self.source)
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        (animator.destination, animator.source) = (destination, source)
        return animator
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            animator.isPresenting = true
            animator.source = source
            animator.destination = destination
        } else {
            animator.isPresenting = false
            animator.source = destination
            animator.destination = source
        }

        return animator
    }
}