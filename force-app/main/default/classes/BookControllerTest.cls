@isTest
private class BookControllerTest {
    
    @TestSetup
    static void makeData() {
        // Create test data for Book__c records
        List<Book__c> testBooks = new List<Book__c>();
        
        testBooks.add(new Book__c(
            Name = 'Book1',
            Title__c = 'The Great Gatsby',
            Author__c = 'F. Scott Fitzgerald',
            Rating__c = 4.5,
            Review__c = 'A classic American novel'
        ));
        
        testBooks.add(new Book__c(
            Name = 'Book2',
            Title__c = '1984',
            Author__c = 'George Orwell',
            Rating__c = 4.8,
            Review__c = 'A dystopian masterpiece'
        ));
        
        testBooks.add(new Book__c(
            Name = 'Book3',
            Title__c = 'To Kill a Mockingbird',
            Author__c = 'Harper Lee',
            Rating__c = 4.7,
            Review__c = 'A powerful story about justice'
        ));
        
        insert testBooks;
    }
    
    @isTest
    static void testGetBooks_WithData() {
        // Test the getBooks method with existing data
        Test.startTest();
        List<Book__c> result = BookController.getBooks();
        Test.stopTest();
        
        // Assert that we get the expected number of books
        System.assertEquals(3, result.size(), 'Should return 3 books');
        
        // Verify the fields are populated correctly
        for (Book__c book : result) {
            System.assertNotEquals(null, book.Id, 'Book Id should not be null');
            System.assertNotEquals(null, book.Name, 'Book Name should not be null');
            System.assertNotEquals(null, book.Title__c, 'Book Title should not be null');
            System.assertNotEquals(null, book.Author__c, 'Book Author should not be null');
            System.assertNotEquals(null, book.Rating__c, 'Book Rating should not be null');
            System.assertNotEquals(null, book.Review__c, 'Book Review should not be null');
        }
        
        // Verify specific book data
        Book__c gatsby = null;
        for (Book__c book : result) {
            if (book.Title__c == 'The Great Gatsby') {
                gatsby = book;
                break;
            }
        }
        System.assertNotEquals(null, gatsby, 'Should find The Great Gatsby');
        System.assertEquals('F. Scott Fitzgerald', gatsby.Author__c, 'Author should match');
        System.assertEquals(4.5, gatsby.Rating__c, 'Rating should match');
    }
    
    @isTest
    static void testGetBooks_NoData() {
        // Delete all test data to test empty result
        delete [SELECT Id FROM Book__c];
        
        Test.startTest();
        List<Book__c> result = BookController.getBooks();
        Test.stopTest();
        
        // Assert that we get an empty list
        System.assertEquals(0, result.size(), 'Should return empty list when no books exist');
        System.assertNotEquals(null, result, 'Result should not be null, should be empty list');
    }
    
    @isTest
    static void testGetBooks_CacheableAnnotation() {
        // Test that the method works correctly (cacheable methods should work normally in tests)
        Test.startTest();
        List<Book__c> firstCall = BookController.getBooks();
        List<Book__c> secondCall = BookController.getBooks();
        Test.stopTest();
        
        // Both calls should return the same data
        System.assertEquals(firstCall.size(), secondCall.size(), 'Both calls should return same number of records');
        System.assertEquals(3, firstCall.size(), 'Should return 3 books on first call');
        System.assertEquals(3, secondCall.size(), 'Should return 3 books on second call');
    }
    
    @isTest
    static void testGetBooks_FieldAccess() {
        // Test that all required fields are accessible and returned
        Test.startTest();
        List<Book__c> result = BookController.getBooks();
        Test.stopTest();
        
        System.assert(result.size() > 0, 'Should have test data');
        
        Book__c testBook = result[0];
        
        // Test that we can access all the fields mentioned in the SOQL query
        try {
            String id = testBook.Id;
            String name = testBook.Name;
            String title = testBook.Title__c;
            String author = testBook.Author__c;
            Decimal rating = testBook.Rating__c;
            String review = testBook.Review__c;
            
            // If we get here without exceptions, field access is working
            System.assert(true, 'All fields are accessible');
        } catch (Exception e) {
            System.assert(false, 'Field access failed: ' + e.getMessage());
        }
    }
    
    @isTest
    static void testCreateBook_Success() {
        // Test successful book creation
        Test.startTest();
        Book__c newBook = BookController.createBook(
            'Test Title',
            'Test Author',
            5,
            'This is a test review',
            '123 Test St',
            'Test City',
            'CA',
            'US',
            '12345'
        );
        Test.stopTest();
        
        // Verify the book was created and returned correctly
        System.assertNotEquals(null, newBook, 'Returned book should not be null');
        System.assertNotEquals(null, newBook.Id, 'Book should have an Id after insert');
        System.assertEquals('Test Title', newBook.Title__c, 'Title should match input');
        System.assertEquals('Test Author', newBook.Author__c, 'Author should match input');
        System.assertEquals(5, newBook.Rating__c, 'Rating should match input');
        System.assertEquals('This is a test review', newBook.Review__c, 'Review should match input');
        
        // Verify the book was actually inserted into the database
        Book__c insertedBook = [SELECT Id, Title__c, Author__c, Rating__c, Review__c FROM Book__c WHERE Id = :newBook.Id];
        System.assertEquals('Test Title', insertedBook.Title__c, 'Database record should match input');
    }
    
    @isTest
    static void testCreateBook_WithNullValues() {
        // Test creating a book with some null values (should still work)
        Test.startTest();
        Book__c newBook = BookController.createBook(
            'Title Only',
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
        );
        Test.stopTest();
        
        // Verify the book was created
        System.assertNotEquals(null, newBook, 'Book should be created even with null values');
        System.assertNotEquals(null, newBook.Id, 'Book should have an Id');
        System.assertEquals('Title Only', newBook.Title__c, 'Title should be set');
        System.assertEquals(null, newBook.Author__c, 'Author should be null');
        System.assertEquals(null, newBook.Rating__c, 'Rating should be null');
        System.assertEquals(null, newBook.Review__c, 'Review should be null');
    }
    
    @isTest
    static void testCreateBook_EmptyStrings() {
        // Test creating a book with empty strings (but valid rating)
        Test.startTest();
        Book__c newBook = BookController.createBook(
            '',
            '',
            1,  // Use 1 instead of 0 to satisfy validation rule
            '',
            '',
            '',
            '',
            '',
            ''
        );
        Test.stopTest();
        
        // Verify the book was created with empty values
        System.assertNotEquals(null, newBook, 'Book should be created with empty strings');
        System.assertNotEquals(null, newBook.Id, 'Book should have an Id');
        System.assertEquals('', newBook.Title__c, 'Title should be empty string');
        System.assertEquals('', newBook.Author__c, 'Author should be empty string');
        System.assertEquals(1, newBook.Rating__c, 'Rating should be 1 (minimum valid value)');
        System.assertEquals('', newBook.Review__c, 'Review should be empty string');
    }
    
    @isTest
    static void testCreateBook_MultipleBooks() {
        // Test creating multiple books in sequence
        Test.startTest();
        Book__c book1 = BookController.createBook('Book One', 'Author One', 3, 'Review One', null, null, null, null, null);
        Book__c book2 = BookController.createBook('Book Two', 'Author Two', 4, 'Review Two', null, null, null, null, null);
        Test.stopTest();
        
        // Verify both books were created with unique IDs
        System.assertNotEquals(null, book1.Id, 'First book should have an Id');
        System.assertNotEquals(null, book2.Id, 'Second book should have an Id');
        System.assertNotEquals(book1.Id, book2.Id, 'Books should have different IDs');
        
        // Verify the data is correct for both
        System.assertEquals('Book One', book1.Title__c, 'First book title should match');
        System.assertEquals('Book Two', book2.Title__c, 'Second book title should match');
        
        // Verify both books exist in database (in addition to the 3 from @TestSetup)
        List<Book__c> allBooks = [SELECT Id FROM Book__c];
        System.assertEquals(5, allBooks.size(), 'Should have 5 total books (3 from setup + 2 new)');
    }
    
    @isTest
    static void testCreateBook_InvalidRating() {
        // Test that invalid rating values are rejected by validation rules
        Test.startTest();
        try {
            BookController.createBook('Test Book', 'Test Author', 0, 'Test Review', null, null, null, null, null);
            System.assert(false, 'Should have thrown an exception for invalid rating');
        } catch (DmlException e) {
            // This is expected - validation rule should prevent rating of 0
            System.assert(e.getMessage().contains('Rating must be between 1 and 5'),
                         'Exception should mention rating validation: ' + e.getMessage());
        }

        try {
            BookController.createBook('Test Book', 'Test Author', 6, 'Test Review', null, null, null, null, null);
            System.assert(false, 'Should have thrown an exception for invalid rating');
        } catch (DmlException e) {
            // This is expected - validation rule should prevent rating of 6
            System.assert(e.getMessage().contains('Rating must be between 1 and 5'),
                         'Exception should mention rating validation: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateBookRating_Success() {
        // Test successful rating update
        List<Book__c> testBooks = [SELECT Id, Rating__c FROM Book__c LIMIT 1];
        Book__c testBook = testBooks[0];
        Decimal originalRating = testBook.Rating__c;
        Decimal newRating = 3.0;
        
        Test.startTest();
        Book__c updatedBook = BookController.updateBookRating(testBook.Id, newRating);
        Test.stopTest();
        
        // Verify the returned book has the updated rating
        System.assertNotEquals(null, updatedBook, 'Updated book should not be null');
        System.assertEquals(testBook.Id, updatedBook.Id, 'Book ID should match');
        System.assertEquals(newRating, updatedBook.Rating__c, 'Rating should be updated');
        
        // Verify the database was actually updated
        Book__c dbBook = [SELECT Id, Rating__c FROM Book__c WHERE Id = :testBook.Id];
        System.assertEquals(newRating, dbBook.Rating__c, 'Database should reflect the updated rating');
        System.assertNotEquals(originalRating, dbBook.Rating__c, 'Rating should be different from original');
    }
    
    @isTest
    static void testUpdateBookRating_ValidRatingRange() {
        // Test updating with different valid ratings (1-5)
        List<Book__c> testBooks = [SELECT Id FROM Book__c LIMIT 3];
        
        Test.startTest();
        Book__c book1 = BookController.updateBookRating(testBooks[0].Id, 1);
        Book__c book2 = BookController.updateBookRating(testBooks[1].Id, 5);
        Book__c book3 = BookController.updateBookRating(testBooks[2].Id, 2.5);
        Test.stopTest();
        
        // Verify all updates worked
        System.assertEquals(1, book1.Rating__c, 'Rating should be 1');
        System.assertEquals(5, book2.Rating__c, 'Rating should be 5');
        System.assertEquals(2.5, book3.Rating__c, 'Rating should be 2.5');
    }
    
    @isTest
    static void testUpdateBookRating_InvalidRating() {
        // Test that invalid ratings are rejected by validation rules
        List<Book__c> testBooks = [SELECT Id FROM Book__c LIMIT 1];
        Book__c testBook = testBooks[0];
        
        Test.startTest();
        try {
            BookController.updateBookRating(testBook.Id, 0);
            System.assert(false, 'Should have thrown an exception for rating of 0');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Rating must be between 1 and 5'), 
                         'Exception should mention rating validation: ' + e.getMessage());
        }
        
        try {
            BookController.updateBookRating(testBook.Id, 6);
            System.assert(false, 'Should have thrown an exception for rating of 6');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Rating must be between 1 and 5'), 
                         'Exception should mention rating validation: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateBookRating_NonExistentBook() {
        // Test updating a book that doesn't exist
        Test.startTest();
        try {
            // Create a fake ID that doesn't exist
            Id fakeId = Book__c.SObjectType.getDescribe().getKeyPrefix() + '000000000000';
            BookController.updateBookRating(fakeId, 3);
            System.assert(false, 'Should have thrown an exception for non-existent book');
        } catch (QueryException e) {
            // This is expected - should get "List has no rows for assignment to SObject"
            System.assert(e.getMessage().contains('List has no rows'), 
                         'Should get no rows exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateBookRating_MultipleUpdates() {
        // Test updating the same book multiple times
        List<Book__c> testBooks = [SELECT Id, Rating__c FROM Book__c LIMIT 1];
        Book__c testBook = testBooks[0];
        
        Test.startTest();
        Book__c update1 = BookController.updateBookRating(testBook.Id, 2);
        Book__c update2 = BookController.updateBookRating(testBook.Id, 4);
        Book__c update3 = BookController.updateBookRating(testBook.Id, 1);
        Test.stopTest();
        
        // Verify each update worked
        System.assertEquals(2, update1.Rating__c, 'First update should set rating to 2');
        System.assertEquals(4, update2.Rating__c, 'Second update should set rating to 4');
        System.assertEquals(1, update3.Rating__c, 'Third update should set rating to 1');
        
        // Verify final state in database
        Book__c finalBook = [SELECT Rating__c FROM Book__c WHERE Id = :testBook.Id];
        System.assertEquals(1, finalBook.Rating__c, 'Final rating should be 1');
    }

    @isTest
    static void testDeleteBook_Success() {
        // Create a standalone book to delete
        Book__c b = new Book__c(Title__c='To Delete', Author__c='X', Rating__c=1, Review__c='');
        insert b;

        Test.startTest();
        BookController.deleteBook(b.Id);
        Test.stopTest();

        // Verify it was deleted
        try {
            Book__c shouldNotExist = [SELECT Id FROM Book__c WHERE Id = :b.Id];
            System.assert(false, 'Query should have thrown because record was deleted');
        } catch (QueryException e) {
            System.assert(e.getMessage().toLowerCase().contains('no rows'), 'Should not find deleted record');
        }
    }

    @isTest
    static void testDeleteBook_NonExistent() {
        // Attempt to delete a non-existent Id and expect an exception
        Id fakeId = Book__c.SObjectType.getDescribe().getKeyPrefix() + '000000000000';
        Test.startTest();
        try {
            BookController.deleteBook(fakeId);
            System.assert(false, 'Expected exception for non-existent record');
        } catch (Exception e) {
            System.assert(true, 'Exception expected: ' + e.getMessage());
        }
        Test.stopTest();
    }
}