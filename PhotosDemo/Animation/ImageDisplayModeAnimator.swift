//
// Created by Vlad Zhavoronkov on 11/10/19.
// Copyright (c) 2019 Zhvrnkov. All rights reserved.
//

import Foundation
import UIKit

protocol ImageDisplayModeAnimatorDelegate: class {
    func onStartTransitionWith(animator: ImageDisplayModeAnimator)
    func onEndTransitionWith(animator: ImageDisplayModeAnimator)
    func getImageView(for animator: ImageDisplayModeAnimator) -> UIImageView
    func getImageViewFrame(for animator: ImageDisplayModeAnimator) -> CGRect
}

class ImageDisplayModeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    weak var source: ImageDisplayModeAnimatorDelegate?
    weak var destination: ImageDisplayModeAnimatorDelegate?

    var transitionImageView: UIImageView?
    var isPresenting: Bool = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? 0.5 : 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ?
            animateZoomInTransition(using: transitionContext) :
            animateZoomOutTransition(using: transitionContext)
    }

    func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toVC = transitionContext.viewController(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from),
              let fromReferenceImageView = self.source?.getImageView(for: self),
              let toReferenceImageView = self.destination?.getImageView(for: self),
              let fromReferenceImageViewFrame = self.source?.getImageViewFrame(for: self)
            else {
            return
        }

        self.source?.onStartTransitionWith(animator: self)
        self.destination?.onStartTransitionWith(animator: self)

        toVC.view.alpha = 0
        toReferenceImageView.isHidden = true
        containerView.addSubview(toVC.view)

        let referenceImage = fromReferenceImageView.image!

        if self.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            self.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }

        fromReferenceImageView.isHidden = true

        let finalTransitionSize = calculateZoomInImageFrame(image: referenceImage, forView: toVC.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [UIView.AnimationOptions.transitionCrossDissolve],
            animations: {
                self.transitionImageView?.frame = finalTransitionSize
                toVC.view.alpha = 1.0
                fromVC.tabBarController?.tabBar.alpha = 0
            },
            completion: { completed in

                self.transitionImageView?.removeFromSuperview()
                toReferenceImageView.isHidden = false
                fromReferenceImageView.isHidden = false

                self.transitionImageView = nil

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.destination?.onEndTransitionWith(animator: self)
                self.source?.onEndTransitionWith(animator: self)
            })
    }

    func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {

    }

    private func calculateZoomInImageFrame(image: UIImage, forView view: UIView) -> CGRect {
        let viewRatio = view.frame.size.width / view.frame.size.height
        let imageRatio = image.size.width / image.size.height
        let touchesSides = (imageRatio > viewRatio)

        if touchesSides {
            let height = view.frame.width / imageRatio
            let yPoint = view.frame.minY + (view.frame.height - height) / 2
            return CGRect(x: 0, y: yPoint, width: view.frame.width, height: height)
        } else {
            let width = view.frame.height * imageRatio
            let xPoint = view.frame.minX + (view.frame.width - width) / 2
            return CGRect(x: xPoint, y: 0, width: width, height: view.frame.height)
        }
    }
}