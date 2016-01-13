//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, SlideMenuDelegate {
    var pan_gr = UIPanGestureRecognizer()
    var isOpen:Bool?
    var menuVC:MenuViewController?
    let menuWidth = UIScreen.mainScreen().bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupDrawer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(index: Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            print("Home\n", terminator: "")
            break
        case 1:
            print("Play\n", terminator: "")
            break
        case 2:
            print("Camera\n", terminator: "")
            break
        default:
            print("default\n", terminator: "")
        }
        closeNavigationDrawer()
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.System)
        btnShowMenu.setImage(self.defaultMenuImage(), forState: UIControlState.Normal)
        btnShowMenu.frame = CGRectMake(0, 0, 30, 30)
        btnShowMenu.addTarget(self, action: "onSlideMenuButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 22), false, 0.0)
            
            UIColor.blackColor().setFill()
            UIBezierPath(rect: CGRectMake(0, 3, 30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 10, 30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 17, 30, 1)).fill()
            
            UIColor.whiteColor().setFill()
            UIBezierPath(rect: CGRectMake(0, 4, 30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 11,  30, 1)).fill()
            UIBezierPath(rect: CGRectMake(0, 18, 30, 1)).fill()
            
            defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
        })
        
        return defaultMenuImage;
    }
    
    func setupDrawer(){
        isOpen = false
        
        menuVC = self.storyboard!.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
        menuVC!.delegate = self
        self.view.addSubview(menuVC!.view)
        self.addChildViewController(menuVC!)
        menuVC!.view.layoutIfNeeded()
        
        // gesture on self.view
        pan_gr = UIPanGestureRecognizer(target: self, action: "moveDrawer:")
        pan_gr.maximumNumberOfTouches = 1
        pan_gr.minimumNumberOfTouches = 1
        //self.pan_gr.delegate = self;
        self.view.addGestureRecognizer(pan_gr)
        
        menuVC!.view.frame=CGRectMake(0 - menuWidth, 0, menuWidth, UIScreen.mainScreen().bounds.size.height);
    }
    
    func onSlideMenuButtonPressed(sender : UIButton){
        if isOpen == true{
            closeNavigationDrawer()
        }
        else{
            openNavigationDrawer()
        }
    }
    
    //MARK:- Open & Close Drawer
    func openNavigationDrawer(){
        isOpen = true
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.menuVC!.view.frame=CGRectMake(0, 0, self.menuWidth, UIScreen.mainScreen().bounds.size.height);
            }, completion:nil)
    }
    
    func closeNavigationDrawer(){
        isOpen = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.menuVC!.view.frame=CGRectMake(0, 0, -self.menuWidth, UIScreen.mainScreen().bounds.size.height);
            }, completion:nil)
    }
    
    //MARK:- Gesture recognizer
    func moveDrawer(recognizer:UIPanGestureRecognizer)
    {
        let translation = recognizer.translationInView(self.view)
        let velocity = recognizer.velocityInView(self.view)
        
        //...1
        if recognizer.state == .Began {
            if velocity.x > menuWidth && self.isOpen == false {
                openNavigationDrawer()
            }else if (velocity.x < -(menuWidth) && self.isOpen == true) {
                closeNavigationDrawer()
            }
        }
        
        //...2
        if recognizer.state == .Changed {
            let movingx = (self.menuVC?.view.center.x)! + translation.x
            if movingx > -menuWidth/2 && movingx < menuWidth/2 {
                self.menuVC?.view.center = CGPointMake(movingx, (self.menuVC?.view.center.y)!);
                recognizer.setTranslation(CGPointMake(0,0), inView: self.view)
            }
        }
        
        //...3
        if recognizer.state == .Ended {
            if self.menuVC?.view.center.x > 0{
                openNavigationDrawer()
            }else if self.menuVC?.view.center.x < 0{
                closeNavigationDrawer()
            }
        }
    }
}
