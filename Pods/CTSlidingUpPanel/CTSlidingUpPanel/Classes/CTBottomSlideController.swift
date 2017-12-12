//
//  BottomSlideController.swift
//  GPSControl Pro
//
//  Created by Gio Andriadze on 6/5/17.
//  Copyright © 2017 Casatrade Ltd. All rights reserved.
//

import UIKit

private var ContentOffsetKVO = 0
private var ConstraintConstantKVO = 1;

public class CTBottomSlideController : NSObject, UIGestureRecognizerDelegate
{
    public enum SlideState
    {
        case collapsed
        case expanded
        case anchored
        case hidden
    }
    
    weak var topConstraint:NSLayoutConstraint!;
    weak var heightConstraint:NSLayoutConstraint!;
    weak var view:UIView!;
    weak var bottomView:UIView!;
    weak var scrollView:UIScrollView?;

    
    
    weak var tabBarController:UITabBarController?;
    weak var navigationController:UINavigationController?;
    
    
    private var expectedHeight:CGFloat!;
    
    private var initalLocation:CGFloat!;
    private var initialTouchLocation:CGFloat!; //changeT
    private var originalConstraint:CGFloat!;
    
    private var panGestureRecognizer:UIPanGestureRecognizer!;
    
    private var visibleHeight:CGFloat = 0;
    private var anchorPoint:CGFloat = 0;
    
    private var isInMotion = false;
    
    
    public var currentState = SlideState.collapsed;
    public weak var delegate:CTBottomSlideDelegate?;
    public var isPanelExpanded:Bool = false;

    
    public init(topConstraint:NSLayoutConstraint, heightConstraint: NSLayoutConstraint, parent: UIView, bottomView: UIView, tabController:UITabBarController?, navController:UINavigationController?, visibleHeight: CGFloat){
        super.init()
        
        self.topConstraint = topConstraint;
        self.heightConstraint = heightConstraint;
        self.view = parent;
        self.bottomView = bottomView;
        if(tabController != nil)
        {
            self.set(tabController: tabController!);
        }
        if(navController != nil)
        {
            self.set(navController: navController!);
        }
        self.initBottomPanel(visibleHeight: visibleHeight)
        addConstraintChangeKVO()
    }
    
    public init(parent: UIView, bottomView: UIView, tabController:UITabBarController?, navController:UINavigationController?, visibleHeight: CGFloat){
        super.init()
        
        self.view = parent;
        self.bottomView = bottomView;
        if(tabController != nil)
        {
            self.set(tabController: tabController!);
        }
        if(navController != nil)
        {
            self.set(navController: navController!);
        }
        
        self.setPrimaryConstraints();
        self.initBottomPanel(visibleHeight: visibleHeight)
        addConstraintChangeKVO()
    }
    
    
    deinit
    {
        print("Bottom panel deiniting");
        removeConstraintChangeKVO();
        
        if scrollView != nil{
            self.removeKVO(scrollView: scrollView!)
        }
        if(panGestureRecognizer != nil){
            bottomView.removeGestureRecognizer(panGestureRecognizer)
        }
    }
    
    private func setPrimaryConstraints()
    {
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        self.topConstraint = NSLayoutConstraint(item: self.bottomView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view,
                                                    attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let startConstraint = NSLayoutConstraint(item: self.bottomView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view,
                                                 attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        let endConstraint = NSLayoutConstraint(item: self.bottomView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view,
                                               attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        self.heightConstraint = NSLayoutConstraint(item: self.bottomView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil,
                                                  attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.height)
        
        
        view.addConstraints([startConstraint, endConstraint, self.topConstraint, self.heightConstraint])
        self.view.layoutIfNeeded()

    }
    
    
    //MARK: Setters
    public func set(navController: UINavigationController)
    {
        self.navigationController = navController;
    }
    
    public func set(tabController: UITabBarController)
    {
        self.tabBarController = tabController;
    }
    
    public func set(table:UITableView)
    {
        if (scrollView != nil){
            self.removeKVO(scrollView: scrollView!)
        }
        scrollView = table;
        //scrollView!.panGestureRecognizer.require(toFail: panGestureRecognizer)
        self.addKVO(scrollView: scrollView!);
    }
    
    
    
    
    //MARK: Toggles
    public func expandPanel()
    {
        if(currentState != .expanded){
            performExpandPanel()
        }
    }
    
    public func anchorPanel()
    {
        if(currentState != .anchored){
            movePanelToAnchor()
        }
    }
    
    public func closePanel()
    {
        if(currentState != .collapsed){
            performClosePanel()
        }
    }
    
    public func hidePanel()
    {
        if(currentState != .hidden)
        {
            performHidePanel()
        }
    }
    
    
    //MARK: init
    private func initBottomPanel(visibleHeight:CGFloat)
    {
        self.visibleHeight = visibleHeight
        
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.moveViewWithGestureRecognizer(panGestureRecognizer:)))
        bottomView.addGestureRecognizer(panGestureRecognizer);
        updateConstraint(visibleHeight);
    }
    
    private func updateConstraint(_ visibleHeight:CGFloat) -> Void
    {        
        let extrasHeight = UIApplication.shared.statusBarFrame.height +
            (self.navigationController?.navigationBar.frame.height ?? 0)
        expectedHeight = self.view.bounds.size.height - extrasHeight;
        
        heightConstraint.constant = expectedHeight;
        topConstraint.constant = (self.view.bounds.size.height - extrasHeight - visibleHeight - (self.tabBarController?.tabBar.frame.size.height ?? 0));
        originalConstraint = topConstraint.constant;
        bottomView.layoutIfNeeded()
    }
    
    
    public func setAnchorPoint(anchor:CGFloat)
    {
        var checkedAnchor = anchor;
        
        
        if(checkedAnchor > 1)
        {
            checkedAnchor = 1;
        }else if(checkedAnchor < 0)
        {
            checkedAnchor = 0;
        }
        
        self.anchorPoint = self.expectedHeight * (1 - checkedAnchor);
    }
    
    
    //MARK: Gesture recognition
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        initalLocation = topConstraint.constant;
        initialTouchLocation = touches.first?.location(in: self.view).y
    }
    
    @objc func moveViewWithGestureRecognizer(panGestureRecognizer:UIPanGestureRecognizer ){
        let touchLocation:CGPoint = panGestureRecognizer.location(in: self.view);
        
        
        if(panGestureRecognizer.state == .changed){
            if initialTouchLocation == nil{
                initialTouchLocation = touchLocation.y;
                initalLocation = topConstraint.constant;
            }
            
            
            topConstraint.constant = initalLocation - (initialTouchLocation - touchLocation.y)
            
            if(topConstraint.constant < 0)
            {
                topConstraint.constant = 0;
            }else if(topConstraint.constant > originalConstraint)
            {
                topConstraint.constant = originalConstraint;
            }
            
            isInMotion = true;
            
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded();
            }, completion: { _ in
                self.isInMotion = false;
            });
            
            
        }else if(panGestureRecognizer.state == .ended){
            
            if initialTouchLocation == nil{ //changeT
                initialTouchLocation = touchLocation.y;
                initalLocation = topConstraint.constant;
            }
            
            if(!panGestureRecognizer.isUp(theViewYouArePassing: self.view)){
                if(initialTouchLocation - touchLocation.y > 23){
                    if(topConstraint.constant < anchorPoint - 23){
                        self.performExpandPanel()
                    }else{
                        self.movePanelToAnchor()
                    }
                }else{
                    
                    
                    if(topConstraint.constant > anchorPoint + 23)
                    {
                        self.performClosePanel()
                    }else{
                        self.movePanelToAnchor()
                    }
                    
                }
            }else
            {
                if(topConstraint.constant > anchorPoint + 23){
                    self.performClosePanel()
                }else{
                    self.movePanelToAnchor()
                }
                
                
            }
            initialTouchLocation = nil;
        }
        
    }
    
    
    private func movePanel(by offset:CGFloat)
    {
        if(initalLocation == nil)
        {
            initalLocation = topConstraint.constant
        }
        
        topConstraint.constant = (initalLocation - offset);
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
    }
    
    private func movePanelToAnchor()
    {
        currentState = .anchored
        
        isPanelExpanded = true;
        isInMotion = true;
        
        self.topConstraint.constant = anchorPoint;
        
        self.view.setNeedsLayout();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded();
            
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        
        delegate?.didPanelAnchor();
    }
    
    private func performExpandPanel()
    {
        
        currentState = .expanded;
        isInMotion = true;
        
        isPanelExpanded = true;
        self.topConstraint.constant = 0;
        
        self.view.setNeedsLayout();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        delegate?.didPanelExpand();
    }
    
    
    private func performClosePanel()
    {
        currentState = .collapsed
        isInMotion = true;
        
        isPanelExpanded = false;
        self.view.layoutIfNeeded();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.topConstraint.constant = self.originalConstraint;
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        delegate?.didPanelCollapse();
    }
    
    private func performHidePanel()
    {
        currentState = .hidden
        isInMotion = true;
        isPanelExpanded = false;
        self.view.layoutIfNeeded();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.topConstraint.constant = self.originalConstraint + self.visibleHeight;
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        delegate?.didPanelCollapse();
    }
    
    private func addConstraintChangeKVO()
    {
        topConstraint.addObserver(self, forKeyPath: "constant", options: [.initial, .new], context: &ConstraintConstantKVO);
    }
    
    private func removeConstraintChangeKVO()
    {
        topConstraint.removeObserver(self, forKeyPath: "constant", context: &ConstraintConstantKVO);
    }
    
    //MARK: Tableview
    private func removeKVO(scrollView: UIScrollView) {
        scrollView.removeObserver(
            self,
            forKeyPath: "contentOffset",
            context: &ContentOffsetKVO
        )
    }
    
    private func addKVO(scrollView: UIScrollView) {
        scrollView.addObserver(
            self,
            forKeyPath: "contentOffset",
            options: [.initial, .new],
            context: &ContentOffsetKVO
        )
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
            
        case .some("contentOffset"):
            checkOffset();
        case .some("constant"):
            firePanelMoved();
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    
    private func firePanelMoved()
    {
        let offset:CGFloat = 1 - (topConstraint.constant/originalConstraint);
        self.delegate?.didPanelMove(panelOffset: offset)
    }
    
    func checkOffset()
    {
        if scrollView == nil || isInMotion{
            return
        }
        
        //    if(scrollView!.contentOffset.y < 0)
        //    {
        //        scrollView!.contentOffset.y = 0
        //        scrollView?.isUserInteractionEnabled = false
        //    }
        
        
        if(scrollView!.contentOffset.y < -50)
        {
            if(currentState == .anchored){
                self.closePanel();
            }else if(currentState == .expanded){
                self.movePanelToAnchor()
            }
        }else if(scrollView!.contentOffset.y > 50){
            if(currentState == .anchored || anchorPoint <= 0){
                self.expandPanel()
            }else if(currentState == .collapsed){
                self.movePanelToAnchor()
            }
        }
    }
    
    
}
