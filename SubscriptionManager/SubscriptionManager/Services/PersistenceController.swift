import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SubscriptionManager")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("Core Data error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Save
    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.success(()))
        }
    }
    
    // MARK: - Delete
    func delete(_ object: NSManagedObject) {
        let context = container.viewContext
        context.delete(object)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}

// MARK: - Core Data Models
@objc(SubscriptionEntity)
public class SubscriptionEntity: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var name: String
    @NSManaged public var category: String
    @NSManaged public var price: Double
    @NSManaged public var billingCycle: String
    @NSManaged public var renewalDate: Date
    @NSManaged public var notes: String?
    @NSManaged public var logoURL: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

extension SubscriptionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscriptionEntity> {
        return NSFetchRequest<SubscriptionEntity>(entityName: "SubscriptionEntity")
    }

    static func from(_ subscription: Subscription) -> SubscriptionEntity {
        let entity = SubscriptionEntity()
        entity.id = subscription.id
        entity.userId = subscription.userId
        entity.name = subscription.name
        entity.category = subscription.category.rawValue
        entity.price = subscription.price
        entity.billingCycle = subscription.billingCycle.rawValue
        entity.renewalDate = subscription.renewalDate
        entity.notes = subscription.notes
        entity.logoURL = subscription.logoURL
        entity.isActive = subscription.isActive
        entity.createdAt = subscription.createdAt
        entity.updatedAt = subscription.updatedAt
        return entity
    }

    func toSubscription() -> Subscription {
        return Subscription(
            id: id,
            userId: userId,
            name: name,
            category: SubscriptionCategory(rawValue: category) ?? .other,
            price: price,
            billingCycle: BillingCycle(rawValue: billingCycle) ?? .monthly,
            renewalDate: renewalDate,
            notes: notes,
            logoURL: logoURL,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
