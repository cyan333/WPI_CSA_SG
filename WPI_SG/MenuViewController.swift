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
    var selectedIndexRow: Int = 0
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    //var t = true
    
    override func viewDidLoad() {
        if(menuList.count == 0){
            let db:SGDatabase
            do{
                db = try SGDatabase.connect()
                menuList = db.getSubMenus(menuId: 0, prefix: "")
                
                /*json part
                 var str = ""
                 str = "["
                 for m in menuList as [Menu]{
                 str += m.toJson()
                 str += ","
                 }
                 str = str.substring(to: str.index(before: str.endIndex))
                 str += "]"
                 */
                
                
                
            }catch {
                print(error)
                do{
                    db = try SGDatabase.connect()
                    menuList = db.getSubMenus(menuId: 0, prefix: "")
                    
                }catch {
                    print("wrong again" + error.localizedDescription)
                }
            }
        }
        
        visibleCellCount = calculateVisibleCellNumber(menuList: menuList)
        tableView.reloadData();
        
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
        menuActionDelegate?.saveMenuState(menuList: menuList)        
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
                }else{
                    counter += subMenusCount
                }
            }
        }
        return nil
    }
    
    func toggleSelectedMenu(menuList: [Menu], index: Int){
        var counter: Int = 0
        for m in menuList as [Menu]{
            counter += 1
            if(counter - 1 == index){
                if(m.isParentMenu){
                    m.isOpened = !m.isOpened
                    //print("parent name: \(m.name)")
                    visibleCellCount = calculateVisibleCellNumber(menuList: self.menuList)
                    let length = calculateVisibleCellNumber(menuList: m.subMenus)
                    //print("child length \(length) at row \(counter)")
                    if(m.isOpened){
                        tableView.insertRows(at: createIndexPathArray(from: selectedIndexRow ,
                                                                      length: length),
                                             with: UITableViewRowAnimation.fade)
                    }else{
                        tableView.deleteRows(at: createIndexPathArray(from: selectedIndexRow ,
                                                                      length: length),
                                             with: UITableViewRowAnimation.fade)
                    }
                    
                    
                }else{
                    //segue
                    print("segue name: \(m.name)")
                    menuActionDelegate?.saveMenuState(menuList: menuList)
                }
                return
            }else if (m.isOpened){
                let subMenusCount = calculateVisibleCellNumber(menuList: m.subMenus)
                if(counter + subMenusCount - 1 >= index){
                    toggleSelectedMenu(menuList: m.subMenus, index: index - counter)
                    return
                }else{
                    counter += subMenusCount
                }
            }
        }
    }
    
    func createIndexPathArray(from: Int, length: Int) -> [IndexPath] {
        var indexPath = [IndexPath]()
        for i in 1...length {
            indexPath.append(IndexPath(row: from + i, section: 0))
        }
        
        return indexPath
    }
}

extension MenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleCellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SGMenuCell")!
        
        if let menu = getSelectedMenu(menuList: menuList, index: indexPath.row) {
            cell.textLabel?.text = menu.name
        }else{
            cell.textLabel?.text = "unknown"
        }
        
        return cell
    }
}

extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        /*switch indexPath.row {
        case 0:
            menuActionDelegate?.openSegue(segueName: "openFirst", sender: nil)
        case 1:
            menuActionDelegate?.openSegue(segueName: "openSecond", sender: nil)
        default:
            break
        }*/
        selectedIndexRow = indexPath.row
        toggleSelectedMenu(menuList: menuList, index: indexPath.row)
    }
}
