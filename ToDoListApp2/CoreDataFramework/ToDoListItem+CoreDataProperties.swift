//
//  ToDoListItem+CoreDataProperties.swift
//  ToDoListApp2
//
//  Created by Stepan Ostapenko on 26.02.2021.
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func getFetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "Task")
    }

    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var status: St
    
    @objc public enum St : Int32, Codable{
        case new = 0
        case done = 1
        case inProrgress = 2
    }
    
    public func getStatusInfo() -> String{
        switch status {
        case St.done:
            return "Finished"
        case St.inProrgress:
            return "In progress"
        case St.new:
            return "New"
        default:
            return ""
        }
    }

}

extension ToDoListItem : Identifiable {

}


