import { LightningElement, wire } from "lwc";
import createBook from "@salesforce/apex/BookController.createBook";
import getCountryPicklistValues from "@salesforce/apex/BookController.getCountryPicklistValues";
import { publish, MessageContext } from "lightning/messageService";
import BOOK_ADDED_CHANNEL from "@salesforce/messageChannel/BookAdded__c";

export default class AddBook extends LightningElement {
  // Country options from Salesforce State and Country Picklists
  countryOptions = [];

  // Initialize form fields using constructor
  constructor() {
    super();
    this.resetForm();
  }

  @wire(MessageContext)
  messageContext;

  // Wire the country picklist values
  @wire(getCountryPicklistValues)
  wiredCountries({ error, data }) {
    if (data) {
        console.log('Country options loaded:', data);
      // Transform the data from Apex to the format expected by lightning-input-address
      this.countryOptions = data.map(country => ({
        label: country.label,
        value: country.value
      }));
      console.log('Country options loaded:', this.countryOptions);
    } else if (error) {
      console.error('Error loading countries:', error);
      this.error = 'Failed to load country list';
    }
  }

  // Handle input changes
  handleTitleChange(event) {
    this.title = event.target.value;
  }

  handleAuthorChange(event) {
    this.author = event.target.value;
  }

  handleRatingChange(event) {
    this.rating = parseInt(event.target.value, 10);
  }

  handleReviewChange(event) {
    this.review = event.target.value;
  }

  // Handle address change from lightning-input-address
  handleAddressChange(event) {
    console.log('Address change event:', event.detail);

    // Extract address components from the event
    this.addressStreet = event.detail.street || '';
    this.addressCity = event.detail.city || '';
    this.addressCountryCode = event.detail.country || '';
    this.addressPostalCode = event.detail.postalCode || '';

    console.log('Address updated:', {
      street: this.addressStreet,
      city: this.addressCity,
      country: this.addressCountryCode,
      postalCode: this.addressPostalCode
    });
  }

  // Handle form submission
  handleAddBook() {
    // Clear previous messages
    this.message = "";
    this.error = "";

    // Basic validation
    if (!this.title || !this.author) {
      this.error = "Please fill in all required fields";
      return;
    }

    if (this.rating < 1 || this.rating > 5) {
      this.error = "Rating must be between 1 and 5";
      return;
    }

    // Call Apex method to create book
    createBook({
      title: this.title,
      author: this.author,
      rating: this.rating,
      review: this.review,
      addressStreet: this.addressStreet,
      addressCity: this.addressCity,
      addressProvince: '', // Not using provinces as requested
      addressCountry: this.addressCountryCode,
      addressPostalCode: this.addressPostalCode
    })
      .then((result) => {
        console.log('Book created successfully:', result);
        this.message = `Book "${this.title}" added successfully!`;

        // Publish message to notify other components
        const payload = { bookId: result.Id };
        publish(this.messageContext, BOOK_ADDED_CHANNEL, payload);

        // Reset form
        this.resetForm();
      })
      .catch((error) => {
        console.error('Error creating book:', error);
        this.error = error.body?.message || "An error occurred while adding the book";
      });
  }

  // Reset form fields
  resetForm() {
    // Form fields
    this.title = "";
    this.author = "";
    this.rating = 1;
    this.review = "";
    this.message = "";
    this.error = "";

    // Address fields
    this.addressStreet = "";
    this.addressCity = "";
    this.addressCountryCode = "";
    this.addressPostalCode = "";

    // Force the lightning-input-address component to reset by querying and resetting it
    const addressInput = this.template.querySelector('lightning-input-address');
    if (addressInput) {
      // Reset the address component by setting all values to empty
      addressInput.country = "";
      addressInput.street = "";
      addressInput.city = "";
      addressInput.countryCode = "";
      addressInput.postalCode = "";
    }
  }
}