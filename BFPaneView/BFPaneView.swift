//
//  PaneView.swift
//  DropWater
//
//  Copyright (c) 2015 Brad Fol. All rights reserved.
//

import UIKit

public class PaneView: UIView, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate {
    private var panGesture: UIPanGestureRecognizer!
    private var animator: UIDynamicAnimator!
    private var paneBehavior: PaneBehavior!
    private var initialCenter: CGPoint!
    
    weak var delegate: PaneViewDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        animator = UIDynamicAnimator(referenceView: superview!)
        animator.delegate = self
        paneBehavior = PaneBehavior(item: self)
        
        initialCenter = center
    }
    
    func panGestureAction(recognizer: UIPanGestureRecognizer) {
        let superview = self.superview!
        
        if recognizer.state == UIGestureRecognizerState.Began {
            animator.removeBehavior(paneBehavior)
            delegate?.paneViewPanBegan?(self)
        } else if recognizer.state == .Changed {
            let point = recognizer.translationInView(superview)
            let distance = calculateDragWithResistance(distance: point.x, range: bounds.width)
            frame.origin.x = distance
            delegate?.paneViewPanChanged?(self, distance: distance)
        } else if recognizer.state == .Ended {
            let velocity = recognizer.velocityInView(superview)
            
            // Check if completed swipe to left
            let targetPoint: CGPoint
            if velocity.x <= 0 && frame.origin.x < -100 { // Successful swipe
                delegate?.paneViewPanEnded(self, success: true)
                targetPoint = CGPoint(x: -frame.size.width / 2 - 20, y: initialCenter.y)
            } else {
                delegate?.paneViewPanEnded(self, success: false)
                targetPoint = initialCenter
            }
            
            paneBehavior.targetPoint = targetPoint
            paneBehavior.velocity = CGPoint(x: velocity.x, y: 0)
            animator.addBehavior(paneBehavior)
        }
    }
    
    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        let success = paneBehavior.targetPoint.x < 0
        delegate?.paneViewAnimationEnded(self, success: success)
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // Exclude all control subviews from receiving pan gesture
        if touch.view != self { return false }
        else { return true }
    }
    
    // Expose panGesture's enabled property
    var panGestureEnabled: Bool {
        get { return panGesture.enabled }
        set(newValue) { panGesture.enabled = newValue }
    }
}

@objc protocol PaneViewDelegate: class {
    func paneViewPanEnded(paneView: PaneView, success: Bool)
    func paneViewAnimationEnded(paneView: PaneView, success: Bool)
    optional func paneViewPanBegan(paneView: PaneView)
    optional func paneViewPanChanged(paneView: PaneView, distance: CGFloat)
}

private func calculateDragWithResistance(distance  distance: CGFloat, range: CGFloat) -> CGFloat {
    if distance > 0 {
        // Provide resistance when dragging to the right
        return (-distance * 0.55 * range) / (-distance * 0.55 - range)
    } else {
        return distance
    }
}

private class PaneBehavior: UIDynamicBehavior {
    var targetPoint = CGPoint() {
        didSet {
            attachmentBehavior.anchorPoint = targetPoint
        }
    }
    var velocity = CGPoint() {
        didSet {
            let currentVelocity = itemBehavior.linearVelocityForItem(item)
            let velocityDelta = CGPointMake(velocity.x - currentVelocity.x, velocity.y - currentVelocity.y)
            itemBehavior.addLinearVelocity(velocityDelta, forItem: item)
        }
    }
    
    private let item: UIDynamicItem
    private let attachmentBehavior: UIAttachmentBehavior
    private let itemBehavior: UIDynamicItemBehavior
    
    init(item: UIDynamicItem) {
        self.item = item
        
        attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: CGPointZero)
        attachmentBehavior.frequency = 3
        attachmentBehavior.damping = 0.4
        attachmentBehavior.length = 0
        
        itemBehavior = UIDynamicItemBehavior(items: [item])
        itemBehavior.density = 1
        itemBehavior.resistance = 2
        
        super.init()
        addChildBehavior(attachmentBehavior)
        addChildBehavior(itemBehavior)
    }
    
}
