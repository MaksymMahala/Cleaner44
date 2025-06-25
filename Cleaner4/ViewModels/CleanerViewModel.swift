import SwiftUI
import AVFoundation
import Contacts

class CleanerViewModel: ObservableObject {
    @Published var showSubscriptionScreenView: Bool = false
    private let contactStore = CNContactStore()
    @Published var similarContacts: [[Contact]] = []
    @Published var emptyContacts: [Contact] = []
    
    func requestAccessToContacts() {
        contactStore.requestAccess(for: .contacts) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.findSimilarContacts()
                    self?.fetchContacts()
                } else {
                    print("Access to contacts denied")
                }
            }
        }
    }
    
    func findSimilarContacts() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var contactsList: [Contact] = []
            let keys = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactIdentifierKey,
                CNContactThumbnailImageDataKey
            ]
            
            let fetchRequest = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            do {
                try self?.contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                    let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
                    let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
                    let uniquePhoneNumbers = Set(phoneNumbers)
                    let imageData = contact.thumbnailImageData

                    contactsList.append(Contact(
                        name: name,
                        phoneNumber: uniquePhoneNumbers.joined(separator: ", "),
                        identifier: contact.identifier,
                        imageData: imageData
                    ))
                }
                
                DispatchQueue.main.async {
                    self?.similarContacts = self?.groupSimilarContacts(contactsList) ?? []
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
            }
        }
    }
    
    private func groupSimilarContacts(_ contacts: [Contact]) -> [[Contact]] {
        var groupedContacts: [[Contact]] = []
        var processed = Set<String>()
        
        for contact in contacts {
            guard !processed.contains(contact.phoneNumber) else { continue }
            
            let similar = contacts.filter {
                ($0.name.lowercased() == contact.name.lowercased() ||
                 $0.phoneNumber.contains(contact.phoneNumber) ||
                 contact.phoneNumber.contains($0.phoneNumber)) &&
                $0.identifier != contact.identifier
            }
            
            if !similar.isEmpty {
                processed.insert(contact.phoneNumber)
                similar.forEach { processed.insert($0.phoneNumber) }
                groupedContacts.append([contact] + similar)
            }
        }
        return groupedContacts
    }
    
    
    func deleteContact(identifier: String) {
        do {
            let request = CNSaveRequest()
            if let contact = try contactStore.unifiedContact(withIdentifier: identifier, keysToFetch: []).mutableCopy() as? CNMutableContact {
                request.delete(contact)
                try contactStore.execute(request)
                findSimilarContacts()
                fetchContacts()
            }
        } catch {
            print("Failed to delete contact: \(error)")
        }
    }
    
    func fetchContacts() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactIdentifierKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor
            ]
            
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            var allContacts: [CNContact] = []
            
            do {
                try self?.contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                    allContacts.append(contact)
                }
                
                let emptyContacts = self?.findEmptyContacts(in: allContacts) ?? []
                
                DispatchQueue.main.async {
                    self?.emptyContacts = emptyContacts
                }
            } catch {
                print("Error fetching contacts: \(error)")
            }
        }
    }
    
    private func findEmptyContacts(in contacts: [CNContact]) -> [Contact] {
        return contacts.compactMap { contact in
            if contact.givenName.isEmpty || contact.phoneNumbers.isEmpty {
                return Contact(
                    name: contact.givenName.isEmpty ? "Unnamed" : contact.givenName,
                    phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "No phone number",
                    identifier: contact.identifier,
                    imageData: contact.thumbnailImageData
                )
            }
            return nil
        }
    }
}
