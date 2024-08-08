# Ghar Ka Bazaar Mobile App

Ghar Ka Bazaar is a comprehensive e-commerce mobile application built using Flutter and Firebase. This project features a complete online shopping experience with home, favourite, cart, and profile screens. Users can add products to their cart or favourites using the provider package and proceed to payments through Razorpay.

## Features

- **Home Screen**: Displays a banner and a list of products. Banners are clickable and navigate to the respective product categories.
- **Favourite Screen**: Users can add products to their favourites for quick access.
- **Cart Screen**: Users can add products to their cart, view, and manage them.
- **Profile Screen**: Users can edit their profile, view orders, and manage account settings.
- **Product Details Screen**: Contains detailed product information with slidable images.
- **Order Management**: Ensures order quantity checks at multiple stages (add to cart, favourite, buy now).
- **Payment Integration**: Integrated with Razorpay for seamless transactions.
- **Vendor UI**: Separate user interface for vendors to manage their products and orders.
- **Splash Screen**: Initial loading screen with the app logo.
- **Out of Stock Feature**: Indicates if a product is out of stock.

## Project Structure

- **Controllers**: Manages business logic and state management.
- **Views**: Contains all the UI components and screens.
- **Models**: Defines the data structures.
- **Services**: Includes API calls and external service integrations.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Rahilsamani/gharKaBazaar.git
   cd gharKaBazaar
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**:

4. **Run the app**:
   ```bash
   flutter run
   ```

## Environment Variables

Ensure to set up your environment variables for sensitive information such as Firebase configuration and Razorpay keys.

## Learning Outcomes

During the development of Ghar Ka Bazaar, I learned a lot about managing data in real-world projects. Key takeaways include:

- Effective state management using the Provider package.
- Implementing secure payment gateways with Razorpay.
- Handling asynchronous operations and ensuring data consistency.
- Integrating Firebase for authentication, storage, and real-time data updates.
- Developing a robust UI for both users and vendors.

## Screenshots

Screenshots will be added soon

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

If you have any questions or feedback, please feel free to contact me at rahilahmed1720@gmail.com.


