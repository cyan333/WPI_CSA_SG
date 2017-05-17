//
//  PresentMenuAnimator.swift
//  WPI_CSA
//
//  Created by NingFangming on 3/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//


import UIKit

class PresentMenuAnimator : NSObject {
}

extension PresentMenuAnimator : UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
         guard
         let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
         let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
         else {
         return
         }
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        // replace main view with snapshot
        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false)
        snapshot!.tag = MenuHelper.snapshotNumber
        snapshot!.isUserInteractionEnabled = false
        snapshot!.layer.shadowOpacity = 0.7
        containerView.insertSubview(snapshot!, aboveSubview: toVC.view)
        fromVC.view.isHidden = true
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                snapshot!.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidth
        },
            completion: { _ in
                fromVC.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        )
    }
}
