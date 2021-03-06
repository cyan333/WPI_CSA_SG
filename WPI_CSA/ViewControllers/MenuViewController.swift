//
//  MenuViewController.swift
//  WPI_CSA
//
//  Created by NingFangming on 3/5/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class SGMenuCell: UITableViewCell {
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var menuStatus: UIImageView!
    
}

class MenuViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var interactor: Interactor? = nil
    
    var keyword: String?
    var menuList = [Menu]()
    var searchResults = [Menu]()
    var visibleCellCount: Int = 0
    var selectedIndexRow: Int = 0
    
    var menuActionDelegate: MenuActionDelegate?
    
    var database: Database?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barTintColor = .clear
        
        searchController.searchBar.tintColor = .white
        searchController.searchBar.subviews[0].subviews.flatMap(){ $0 as? UITextField }.first?.tintColor = .lightGray
        
        tableView.tableHeaderView = searchController.searchBar
        
        if let keyword = keyword{
            searchController.searchBar.text = keyword
        }
        
        do{
            database = try Database.connect()
            
            /*json part
             var str = ""
             str = "["
             for m in menuList as [Menu]{
             str += m.toJson()
             str += ","
             }
             str = String(str[..<str.index(before: str.endIndex)])
             str += "]"
             */
            
            
        }catch {
            print(error)
        }
        if(menuList.count == 0){
            if let database = database{
                Utils.menuOrderList = []
                menuList = database.getSubMenus(by: 0, withPrefix: "")
                
            }
        }
        
        visibleCellCount = calculateVisibleCellNumber(menuList: menuList)
        tableView.reloadData();
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let coloredView = ColoredView(frame: self.view.bounds)
        coloredView.setVerticalGradient(topColor: UIColor(hexString: "93B9C8"),
                                        bottomColor: UIColor(hexString: "A57363"))
        
        self.tableView.backgroundView = coloredView
        
        addOrUpdateStatusBGView(viewController: self, color: UIColor(hexString: "93B9C8"))
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
        let keywrd = searchController.searchBar.text
        if keywrd == "" {
            menuActionDelegate?.displayArticleAndSaveMenuState(article: nil, keyword: nil, menuList: menuList)
        }else{
            menuActionDelegate?.displayArticleAndSaveMenuState(article: nil, keyword: keywrd, menuList: searchResults)
        }
        if searchController.isActive {
            dismiss(animated: true, completion: nil)
        }
        searchController.view.removeFromSuperview()
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
                    visibleCellCount = calculateVisibleCellNumber(menuList: self.menuList)
                    let length = calculateVisibleCellNumber(menuList: m.subMenus)
                    if(m.isOpened){
                        tableView.insertRows(at: createIndexPathArray(from: selectedIndexRow ,
                                                                      length: length),
                                             with: UITableViewRowAnimation.fade)
                        tableView.reloadRows(at: [IndexPath(row: selectedIndexRow, section: 0)],
                                             with: UITableViewRowAnimation.none)
                    }else{
                        tableView.deleteRows(at: createIndexPathArray(from: selectedIndexRow ,
                                                                      length: length),
                                             with: UITableViewRowAnimation.fade)
                        tableView.reloadRows(at: [IndexPath(row: selectedIndexRow, section: 0)],
                                             with: UITableViewRowAnimation.none)
                    }
                    
                    
                }else{
                    var article: Article?
                    if let db = database {
                        article = db.getArticle(byMenuId: m.id)
                    }
                    let keywrd = searchController.searchBar.text
                    if keywrd == "" {
                        menuActionDelegate?.displayArticleAndSaveMenuState(article: article, keyword: nil, menuList: self.menuList)
                    }else{
                        menuActionDelegate?.displayArticleAndSaveMenuState(article: article, keyword: keywrd, menuList: searchResults)
                    }
                    if searchController.isActive {
                        dismiss(animated: false, completion: nil)
                    }
                    searchController.view.removeFromSuperview()
                    dismiss(animated: true, completion: nil)                    
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
    
    func searchForArticles(keyword: String){
        if let db = database {
            searchResults = db.searchArticles(withKeyword: keyword)
        }
        tableView.reloadData()
    }
}

//MARK: Table view delegates
extension MenuViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text != "" {
            return searchResults.count
        }
        return visibleCellCount
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SGMenuCell") as! SGMenuCell
        
        if searchController.searchBar.text != "" {
            cell.menuLabel.text = searchResults[indexPath.row].name
            cell.menuStatus.image = nil
            return cell
        }
        
        if let menu = getSelectedMenu(menuList: menuList, index: indexPath.row) {
            cell.menuLabel.text = menu.name
            if(menu.isParentMenu){
                if(menu.isOpened){
                    cell.menuStatus.image = UIImage(named: "menuExpanded.png");
                }else{
                    cell.menuStatus.image = UIImage(named: "menuCollapsed.png");
                }
            }else{
                cell.menuStatus.image = nil
            }
        }
        
        return cell
    }
}

extension MenuViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndexRow = indexPath.row
        if searchController.searchBar.text != "" {
            toggleSelectedMenu(menuList: searchResults, index: indexPath.row)
        }else{
            toggleSelectedMenu(menuList: menuList, index: indexPath.row)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

//MARK: Search view delegates
extension MenuViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchForArticles(keyword: searchController.searchBar.text!)
    }
}

