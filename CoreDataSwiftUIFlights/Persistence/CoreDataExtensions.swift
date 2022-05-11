//
//  FoundationExtensions.swift
//  CoreDataTest
//
//  Created by Tatiana Kornilova on 17.02.2022.
//

import CoreData

extension NSManagedObjectContext {
    
    func saveContext (){
        if self.hasChanges {
            do{
                try self.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}

