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
    var visibleCells: Int = 0
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    //let menuItems = ["First", "Second"]
    
    
    override func viewDidLoad() {
        let startTime = CFAbsoluteTimeGetCurrent()
        let db:SGDatabase
        do{
            db = try SGDatabase.connect()
            //print("ok")
            //db.createTable()
            //db.run(query: "")
            menuList = db.getSubMenus(menuId: 0)
            var str = ""
            str = "["
            for m in menuList as [Menu]{
                str += m.toJson()
                str += ","
            }
            str = str.substring(to: str.index(before: str.endIndex))
            str += "]"
            //print(str)
        }catch {
            print(error)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
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
    
}

extension MenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = menuList[indexPath.row].name
        return cell
    }
}

extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            print("1")
            //menuActionDelegate?.openSegue(segueName: "openFirst", sender: nil)
        case 1:
            print("2")
            //menuActionDelegate?.openSegue(segueName: "openSecond", sender: nil)
        default:
            break
        }
    }
}
