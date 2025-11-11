public with sharing class BookController {
    @AuraEnabled(cacheable=true)
    public static List<Book__c> getBooks() {
        return [
w            SELECT Id, Name, Title__c, Author__c, Rating__c, Review__c, Status__c,
                   Book_address__Street__s, Book_address__City__s,
                   Book_address__StateCode__s, Book_address__CountryCode__s,
                   Book_address__PostalCode__s
            FROM Book__c
        ];
    }
    
    @AuraEnabled
    public static Book__c createBook(
        String title,
        String author,
        Integer rating,
        String review,
        String status,
        String addressStreet,
        String addressCity,
        String addressProvince,
        String addressCountry,
        String addressPostalCode
    ) {
        System.debug('=== createBook called ===');
        System.debug('addressStreet: ' + addressStreet);
        System.debug('addressCity: ' + addressCity);
        System.debug('addressProvince: ' + addressProvince);
        System.debug('addressCountry: ' + addressCountry);
        System.debug('addressPostalCode: ' + addressPostalCode);
        System.debug('status: ' + status);

        Book__c newBook = new Book__c(
            Title__c = title,
            Author__c = author,
            Rating__c = rating,
            Review__c = review,
            Status__c = status,
            Book_address__Street__s = addressStreet,
            Book_address__City__s = addressCity,
            Book_address__StateCode__s = addressProvince,
            Book_address__CountryCode__s = addressCountry,
            Book_address__PostalCode__s = addressPostalCode
        );

        System.debug('Book before insert: ' + JSON.serializePretty(newBook));
        insert newBook;
        System.debug('Book after insert: ' + JSON.serializePretty(newBook));
        return newBook;
    }
    
    @AuraEnabled
    public static Book__c updateBookRating(Id bookId, Decimal newRating) {
        Book__c book = [SELECT Id, Rating__c FROM Book__c WHERE Id = :bookId LIMIT 1];
        book.Rating__c = newRating;
        update book;
        return book;
    }

    @AuraEnabled
    public static Book__c updateBookStatus(Id bookId, String newStatus) {
        Book__c book = [SELECT Id, Status__c FROM Book__c WHERE Id = :bookId LIMIT 1];
        book.Status__c = newStatus;
        update book;
        return book;
    }

    @AuraEnabled
    public static void deleteBook(Id bookId) {
        // Delete the specified book record
        Book__c book = [SELECT Id FROM Book__c WHERE Id = :bookId LIMIT 1];
        delete book;
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getCountryPicklistValues() {
        List<PicklistOption> countries = new List<PicklistOption>();

        // Access the global State and Country Picklist values through the compound address field
        Schema.DescribeFieldResult countryField = Book__c.Book_address__CountryCode__s.getDescribe();
        List<Schema.PicklistEntry> picklistValues = countryField.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                countries.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }

        System.debug('Loaded ' + countries.size() + ' countries from State and Country Picklists');
        return countries;
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getStatusPicklistValues() {
        List<PicklistOption> statuses = new List<PicklistOption>();

        // Access the Status__c picklist values
        Schema.DescribeFieldResult statusField = Book__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = statusField.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                statuses.add(new PicklistOption(entry.getLabel(), entry.getValue()));
            }
        }

        System.debug('Loaded ' + statuses.size() + ' status values');
        return statuses;
    }

    public class PicklistOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}