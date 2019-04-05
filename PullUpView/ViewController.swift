//
//  ViewController.swift
//  PullUpView
//
//  Created by Mihai A Ruber on 4/4/19.
//  Copyright © 2019 Mihai A Ruber. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Properties
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    var cardVisible: Bool = false
    var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    //MARK: - Constants
    let cardHeight: CGFloat = 600
    let cardHandleAreaHeight: CGFloat = 65
    
    //MARK - Enum
    enum CardState {
        case expanded
        case collapsed
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCard()
    }
    
    // Setup the card view
    private func setupCard() {
        print("card setup")
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChildViewController(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognizer:)))
        
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handleCardTap(recognizer: UITapGestureRecognizer) {
        print("did press tap")
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
        
    }
    
    @objc private func handleCardPan(recognizer: UIPanGestureRecognizer) {
        print("did pan")
        switch recognizer.state {
        case .began:
            // startTransition
            startInteractiveTranstition(state: nextState, duration: 0.9)
        case .changed:
            // update transition
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // continue transition
            continueInteractiveTransition()
        default:
            // default transition
            break
            
        }
    }
    
    func animateTransitionIfNeeded(state:CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    
    func startInteractiveTranstition(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            // run animations
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
        
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        
    }


}











