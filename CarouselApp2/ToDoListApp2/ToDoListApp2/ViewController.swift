//
//  ViewController.swift
//  ToDoListApp2
//
//  Created by Stepan Ostapenko on 26.02.2021.
//

import UIKit
import CoreGraphics
import CoreDataFramework
import WidgetKit
class ViewController: UIViewController, UITableViewDelegate {
    
    let cellID = "cell"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var order = 0;
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        title = "To Do List"
        tableView.backgroundColor = UIColor(named: "MainBackground")
        view.addSubview(tableView)
        getAllItems()
        firstEntrance()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.register( myTableViewCell.self, forCellReuseIdentifier: cellID)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(organize))
    }
    
    func firstEntrance(){
        for item in models {
            if (item.status == ToDoListItem.St.new){
                updateItem(item: item, newName: item.name!, newSt: ToDoListItem.St.inProrgress)
            }
        }
    }
    
    @objc func organize(fromUI: Bool = true){
        order += 1
        print(order)
        getAllItems()
    }
    
    func sortToDoItems(first: ToDoListItem, second:  ToDoListItem) ->  Bool{
        switch self.order % 3 {
        // new top
        case 0:
            if (first.status == ToDoListItem.St.done){
                return false
            }
            else if (first.status == ToDoListItem.St.inProrgress && second.status != ToDoListItem.St.done){
                return false
            }
            // done top
        case 1:
            if (first.status == ToDoListItem.St.new){
                return false
            }
            else if (first.status == ToDoListItem.St.inProrgress && second.status != ToDoListItem.St.new){
                return false
            }
            // in progress top
        case 2:
            if (first.status != ToDoListItem.St.inProrgress && second.status == ToDoListItem.St.inProrgress){
                return false
            }
            else if ((first.status == ToDoListItem.St.done || first.status == ToDoListItem.St.new) && second.status != ToDoListItem.St.inProrgress){
                return true
            }
        default:
            return true
        }
        return true
    }
    
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "New Item", message: "Enter new Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: {[weak self] _  in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self?.createItem(name: text)
        }))
        present(alert, animated: true)
    }
    
    //MARK: - Item functions
    
    func getAllItems(){
        do{
            models = try context.fetch(ToDoListItem.fetchRequest()) as! [ToDoListItem]
            models.sort(by: sortToDoItems)
            WidgetCenter.shared.reloadAllTimelines()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch{
            
            
        }
    }
    
    func createItem(name:  String){
        let newItem = ToDoListItem(context: context)
        newItem.name = name;
        newItem.createdAt = Date()
        newItem.status = ToDoListItem.St.new
        do{
            try context.save()
            getAllItems()
        }
        catch{
            
        }
    }
    
    
    func deleteItem(item: ToDoListItem){
        context.delete(item)
        
        do{
            try context.save()
            getAllItems()
        }
        catch{
            
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String, newSt: ToDoListItem.St){
        item.name = newName
        item.status = newSt
        do{
            try context.save()
            getAllItems()
        }
        catch{
            
        }
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! myTableViewCell
        cell.taskData = model
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = models[indexPath.row]
        let texF = UITextField()
        texF.text = item.name
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _  in
            
            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: {[weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else{
                    return
                }
                
                self?.updateItem(item: item, newName: newName, newSt: item.status)
            }))
            self.present(alert, animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:{ [weak self] _ in
            self?.deleteItem(item: item)
        }))
        
        sheet.addAction(UIAlertAction(title: "Finish", style: .default, handler:{ [weak self] _ in
            item.status = ToDoListItem.St.done
            self?.updateItem(item: item, newName: item.name!, newSt: item.status)
        }))
        
        present(sheet, animated: true)
    }
}
