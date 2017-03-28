//
//  MenuViewController.swift
//  WPI SG
//
//  Created by NingFangming on 3/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class MenuViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var interactor: Interactor? = nil
    
    var menuList = [Menu]()
    var visibleCellCount: Int = 0
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    //let menuItems = ["First", "Second"]
    
    
    override func viewDidLoad() {
        //let startTime = CFAbsoluteTimeGetCurrent()
        let db:SGDatabase
        do{
            db = try SGDatabase.connect()
            menuList = db.getSubMenus(menuId: 0)
            //json part
            var str = ""
            str = "["
            for m in menuList as [Menu]{
                str += m.toJson()
                str += ","
            }
            str = str.substring(to: str.index(before: str.endIndex))
            str += "]"
            //json part end
            
            visibleCellCount = calculateVisibleCellNumber(menuList: menuList)
            tableView.reloadData();
            
        }catch {
            print(error)
        }
        
        //alet timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        //print("Time elapsed for \(title): \(timeElapsed) s")
        /*var t = [Menu]()
        
        for index in 1...90 {
            t.append(Menu(id: index, name: "haha let me see how big!!!!!!!"))
        }*/
        
    }
    
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Left)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeMenu(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds){
            completion()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismiss(animated: true){
            self.delay(seconds: 0.5){
                self.menuActionDelegate?.reopenMenu()
            }
        }
    }
    
    func calculateVisibleCellNumber(menuList: [Menu]) -> Int{
        var count: Int = menuList.count
        for m in menuList as [Menu]{
            if(m.isOpened){
                count += calculateVisibleCellNumber(menuList: m.subMenus)
            }
        }
        return count
    }
    
    func getSelectedMenu(menuList: [Menu], index: Int) -> Menu?{
        var counter: Int = 0
        for m in menuList as [Menu]{
            counter += 1
            if(counter - 1 == index){
                return m
            }else if (m.isOpened){
                let subMenusCount = calculateVisibleCellNumber(menuList: m.subMenus)
                if(counter + subMenusCount - 1 >= index){
                    return getSelectedMenu(menuList: m.subMenus, index: index - counter)
                }
            }
        }
        return nil
    }
}

extension MenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleCellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        if let menu = getSelectedMenu(menuList: menuList, index: indexPath.row) {
            cell.textLabel?.text = menu.name
        }else{
            cell.textLabel?.text = "unknown"
        }
        
        cell.textLabel?.text = menuList[indexPath.row].name
        return cell
    }
}

extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /*switch indexPath.row {
        case 0:
            menuActionDelegate?.openSegue(segueName: "openFirst", sender: nil)
        case 1:
            menuActionDelegate?.openSegue(segueName: "openSecond", sender: nil)
        default:
            break
        }*/
        if let menu = getSelectedMenu(menuList: menuList, index: indexPath.row) {
            if(menu.isParentMenu){
                print("parent")
            }else{
                print("child")
            }
        }
    }
}
