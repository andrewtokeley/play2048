//
//  FirestoreServiceInterface.swift
//  trapr
//
//  Created by Andrew Tokeley on 24/10/18.
//  Copyright © 2018 Andrew Tokeley . All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FirestoreEntityServiceError: Error {
    case entityHasNoId
    case notImplemented
    case deleteFailed
    case addFailed
    case updateFailed
    case generalError
    case entityNotFound
    case accessDenied
}

class FirestoreEntityService<T: FirestoreEntity>  {
    
    var firestore: Firestore
    private var entityCollectionName: String
    
    var collection: CollectionReference {
        return self.firestore.collection(entityCollectionName)
    }
    
    init(firestore: Firestore, collectionName: String) {
        self.firestore = firestore
        self.entityCollectionName = collectionName
    }
        
    /**
     Adds a new entity to firestore. If the document representing the entity already exists it is updated, otherwise a new document is created. Documents will immediately be written to the cache, and will try to be written to the server too. If offline, the documents will be written the next time the app goes online.
     
     - parameters:
        - entity: an object that represents a document in firestore that implements DocumentSerializable
        - completion: closure that is called after the add action is complete. The closure will be passed a String? representing the id of the newly added document or an Error? if something went wrong.
     - returns:
     Returns the id of the document that has been created or update. If the method fails, there may be no document with this id in the database.
     */
    func add(entity: T, batch: WriteBatch? = nil, completion: ((T?, Error?) -> Void)?) -> String {
        
        // get a reference to where the document will be saved
        let reference = documentReference(entity: entity)
        
        var addedEntity = entity
        
        // in case the entity doesn't already have an id this will ensure it does
        addedEntity.id = reference.documentID
        
        if batch == nil {
            // add the data
            reference.setData(entity.dictionary) { (error) in
                completion?(addedEntity, error)
            }
        } else {
            batch!.setData(entity.dictionary, forDocument: reference)
            completion?(addedEntity, nil)
        }
        
        // immediately return the reference documentid
        return reference.documentID
    }
    
    /**
     Adds a new entity to firestore. Documents will immediately be written to the cache, and will try to be written to the server too. If offline, the documents will be written the next time the app goes online.
     
     - parameters:
        - entities: an array of objects that represent documents in firestore. Each entity must implement DocumentSerializable.
        - completion: closure that is called after the add action is complete. The closure will be passed a String? representing the id of the newly added document or an Error? if something went wrong. The block will not be called if offline :-(
     */
    func add(entities: [T], completion: (([T], Error?) -> Void)?) {
        
        let batch = firestore.batch()
        var addedEntities = entities
        
        for entity in addedEntities {
            var addedEntity = entity
            let docRef = documentReference(entity: entity)
            addedEntity.id = docRef.documentID
            batch.setData(addedEntity.dictionary, forDocument:docRef, merge: true)
            addedEntities.append(addedEntity)
        }
        
        batch.commit { (error) in
            completion?(addedEntities, error)
        }
    }
    
    /**
     Updates the document represented by the entity. If the document matching the entity doesn't exist in Firestore, calling this method will NOT add a new document and an error will be returned in the completion closure. Documents will immediately be written to the cache, and will try to be written to the server too. If offline, the documents will be written the next time the app goes online.
     
     - parameters:
        - entity: the entity to update
        - completion: closure that is called after the save action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed. The block will still be called if offline.
     
     */
    func update(entity: T, completion: ((Error?) -> Void)?) {
        
        // if the entity doesn't have an id then it's not in Firestore
        guard let _ = entity.id else {
            completion?(FirestoreEntityServiceError.entityHasNoId)
            return
        }
        
        let reference = self.documentReference(entity: entity)
        
        reference.updateData(entity.dictionary) { (error) in
            completion?(error)
        }
    }
    
    /**
     Get a specific entity by its id. By default data is read from the cache. You can override this by setting the source.
     
     - parameters:
        - id: the entity id that matches a documentId the collection
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed.
     */
    func get(id: String, source: FirestoreSource = .default, completion: ((T?, Error?) -> Void)?) {
        let reference = self.collection.document(id)
        reference.getDocument(source: source) { (snapshot, error) in
            completion?(self.getEntityFromDocumentSnapshot(snapshot: snapshot), error)
        }
    }
    
    /**
     Get an array of entities matching the ids. This method will only ever look in the cache.
     
     - parameters:
        - ids: array of entity ids
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated array of entities or an Error if the get action failed.
     */
    func get(ids: [String], source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        
        // currently no way to do this in a single call, need to get each document and merge
        var results = [T]()
        var lastError: Error?
        
        let dispatchGroup = DispatchGroup()
        for id in ids {
            dispatchGroup.enter()
            self.get(id: id, source: source) { (result, error) in
                if let error = error {
                    lastError = error
                } else if let result = result {
                    results.append(result)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion?(results, lastError)
        }
    }
    
    /**
     Retrieve an array of all entities. You can override the default behaviour of only reading from the cahce by setting the source.
     
     - important:
     Be careful that you don't return too many large results. The default result set is 1000, but for large datasets this could still be too large. Consider whether you can filter the results
     
     - parameters:
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - limit: Limit on how many records to return. Default is 100.
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated array of entities or an Error if the get action failed.
     */
    func get(source: FirestoreSource = .default, limit: Int = 1000, completion: (([T], Error?) -> Void)?) {
        self.collection.getDocuments(source: source) { (snapshot, error) in
            if let error = error {
                completion?([T](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
    }
    
    /**
     Retrieve an array of all entities ordered (ascending) by the given field. You can override the default behaviour of only reading from the cahce by setting the source.
     
     - important:
     Be careful that you don't return too many large results. The default result set is 1000, but for large datasets this could still be too large. Consider whether you can filter the results
     
     - parameters:
        - orderByField: the name of the first to order (always ascending)
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated array of entities or an Error if the get action failed.
     */
    func get(orderByField: String, source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        self.get(orderByField: orderByField, limit: 3000, source: source) { (result, error) in
            completion?(result, error)
        }
    }
    
    /**
     Retrieves all documents from the Firestore that are located in the entities collection. You can override the default behaviour of only reading from the cahce by setting the source.
     
     - parameters:
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - orderByField: the name of the field to order by (ascending)
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed.
     */
    func get(orderByField: String, limit: Int, source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        
        self.collection.order(by: orderByField).limit(to: limit).getDocuments(source: source) { (snapshot, error) in
            
            if let error = error {
                completion?([T](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
        
    }
    
    /**
     Retrieves all documents from the Firestore that are located in the entities collection where the field is equal to value supplied.
     
     - parameters:
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - whereField: the name of the field to compare with
        - isEqualTo:
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed.
     */
    func get(whereField: String, isEqualTo: Any, source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        self.collection.whereField(whereField, isEqualTo: isEqualTo).getDocuments(source: source) { (snapshot, error) in
            
            if let error = error {
                completion?([T](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
    }
    
    /**
     Retrieves all documents from the Firestore that are located in the entities collection where the field is greater than the value supplied. Always reads from the cache.
     
     - Parameters:
        - whereField: the name of the field to compare with
        - isEqualTo: value to compare against
        - orderByField: the name of the field to order by (ascending)
        - limit: maximum number of records that will be returned
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed.
     */
    func get(whereField: String, isEqualTo: Any, orderByField: String, limit: Int, source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        
        self.collection.whereField(whereField, isEqualTo: isEqualTo).order(by: orderByField).limit(to: limit).getDocuments(source: source) { (snapshot, error) in
            
            if let error = error {
                completion?([T](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
        
    }
    
    /**
     Retrieves all documents from the Firestore that are located in the entities collection where the field is greater than the value supplied.
     
     - Parameters:
        - whereField: the name of the field to compare with
        - isGreaterThan: value to compare against
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed.
     */
    func get(whereField: String, isGreaterThan: Any, source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        
        self.collection.whereField(whereField, isGreaterThan: isGreaterThan).getDocuments(source: source) { (snapshot, error) in
            
            if let error = error {
                completion?([T](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
        
    }
    
    /**
     Retrieves all documents from the Firestore that are located in the entities collection where the field is less than the value supplied.
     
     - parameters:
        - whereField: the name of the field to compare with
        - isLessThan: value to compare against
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed.
     */
    func get(whereField: String, isLessThan: Any, source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        
        self.collection.whereField(whereField, isLessThan: isLessThan).getDocuments(source: source) { (snapshot, error) in
            
            if let error = error {
                completion?([T](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
    }
    
    /**
     Retrieves all documents from the Firestore that are located in the entities collection where the field is between isGreaterThan and isLessThan the values supplied.
     
     - Parameters:
        - whereField: the name of the field to compare with.
        - isGreaterThan: value to compare against.
        - andLessThan: value to compare against.
        - source: (optional) unless specified data will be retrieved from the server if possible, otherwise cache
        - completion: closure that is called after the get action is complete. The closure will be passed a fully instantiated entity or an Error if the get action failed.
     */
    func get(whereField: String, isGreaterThan: Any, andLessThan: Any, source: FirestoreSource = .default, completion: (([T], Error?) -> Void)?) {
        
        self.collection.whereField(whereField, isGreaterThan: isGreaterThan).whereField(whereField, isLessThan: andLessThan).getDocuments(source: source) { (snapshot, error) in
            
            if let error = error {
                completion?([T](), error)
            } else {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                completion?(entities, nil)
            }
        }
    }
    
    /**
     Adds a delete operation to the batch for the given entityId. The caller of this operation is responsible for committing the batch.
     
     - parameters:
        - entityId: the entity id representing the document to delete
        - batch: the `WriteBatch` to add the delete operation to
     */
    func delete(entityId: String, batch: WriteBatch) {
        let reference = self.collection.document(entityId)
        batch.deleteDocument(reference)
    }
    
    /**
     Deletes the document, referenced by the entity, from firestore
     
     - parameters:
        - entityId: the entity id representing the document to delete
        - completion: closure that is called after the delete action is complete. The closure will be passed Error if the delete action failed, otherwise nil.
     */
    func delete(entityId: String, completion: ((Error?) -> Void)?) {
        
        let reference = self.collection.document(entityId)
        
        // perform the delete
        reference.delete { (error) in
            completion?(error)
        }
    }
    
    /**
     Deletes the document, referenced by the entity, from firestore
     
     - parameters:
        - entity: an object that represents a document in firestore that implements DocumentSerializable
        - completion: closure that is called after the delete action is complete. The closure will be passed Error if the delete action failed, otherwise nil. Unlike Firestore API this closure will be called even if you're offline.
     */
    func delete(entity: T, completion: ((Error?) -> Void)?) {
        if let id = entity.id {
            self.delete(entityId: id) { (error) in
                completion?(error)
            }
        } else {
            completion?(FirestoreEntityServiceError.entityHasNoId)
        }
    }
    
    /**
     Deletes all the document, referenced by the entities. Documents will be deleted inside a batch operation.
     
     - parameters:
        - entities: array of enitites that represents a document in firestore that implements DocumentSerializable
        - completion: closure that is called after the delete action is complete. The closure will be passed Error if the delete action failed, otherwise nil. Unlike Firestore API this closure will be called even if you're offline.
     */
    func delete(entities: [T], completion: ((Error?) -> Void)?) {
        let batch = self.firestore.batch()
        for entity in entities {
            let documentReference = self.documentReference(entity: entity)
            batch.deleteDocument(documentReference)
        }
        // fire and forget - if offline the batch will wait until online to commit
        batch.commit()
        
        completion?(nil)
    }

    /**
     Deletes all the document, referenced by the entityIds. Documents will be deleted inside a batch operation.
     
     - parameters:
        - entityIds: array of enitity ids that represent the documents in firestore to remove
        - completion: closure that is called after the delete action is complete. The closure will be passed Error if the delete action failed, otherwise nil. Unlike Firestore API this closure will be called even if you're offline.
     */
    func delete(entityIds: [String], completion: ((Error?) -> Void)?) {
        let batch = firestore.batch()
        
        for id in entityIds {
            self.delete(entityId: id, batch: batch)
        }
        
        // fire and forget, deletes will be removed from cache, even if offline
        batch.commit()
        
        completion?(nil)
    }
    
    /**
     Deletes all documents from the firestore collection. Will attempt to read documents from the server, but will default to only deleting documents it can see in the cache, if offline. Documents are deleted in a batch.
     
     - parameters:
     - completion: optional closure that is called after the delete action is complete. The closure will be passed Error if the delete action failed, otherwise nil.
     */
    func deleteAllEntities(completion: ((Error?) -> Void)?) {

        self.collection.getDocuments(source: .default) { (snapshot, error) in
            if let snapshot = snapshot {
                let entities = self.getEntitiesFromQuerySnapshot(snapshot: snapshot)
                self.delete(entities: entities, completion: { (error) in
                    completion?(error)
                })
            } else {
                // leave straight away, nothing to delete
                completion?(nil)
            }
        }
    }
    
    //MARK: - Private functionas
    
    /**
     Extract typed entity from a document snapshot.
     
     - parameters:
     - snapshot: a DocumentSnapshot instance as returned from Firestore query
     */
    func getEntityFromDocumentSnapshot(snapshot: DocumentSnapshot?) -> T? {

        var result: T?
        if let snapshot = snapshot, let data = snapshot.data() {
            result = T(dictionary: data)
            result?.id = snapshot.documentID
        }
        return result
    }
    
    /**
     Extract typed entities from the document snapshot.
     
     - parameters:
        - snapshot: a QuerySnapshot instance as returned from Firestore query
     */
    func getEntitiesFromQuerySnapshot(snapshot: QuerySnapshot?) -> [T] {
        
        var results = [T]()
        
        if let documents = snapshot?.documents {
            for document in  documents {
                var result = T(dictionary: document.data())
                result?.id = document.documentID
                if result != nil {
                    results.append(result!)
                }
            }
        }
        return results
    }
    
    /**
     Returns a DocumentReference pointing to where the entity exists, or will exist, in Firestore.
     */
    private func documentReference(entity: T) -> DocumentReference {
        var docRef: DocumentReference
        if let id = entity.id {
            docRef = self.collection.document(id)
        } else {
            docRef = self.collection.document()
        }
        return docRef
    }
}

class FirestoreService  {
    
    var firestore: Firestore
    
    init(firestore: Firestore) {
        self.firestore = firestore
    }
}
