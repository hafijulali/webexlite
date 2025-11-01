# WebexLite

A lightweight and performant Flutter implementation of a Webex client, focusing on core functionalities and an optimized user experience. This application leverages the `webexapis` Flutter package for seamless integration with Webex services.

## Features

*   **Real-time Messaging**: Send and receive messages in Webex spaces.
*   **Space Management**: View and interact with your Webex spaces.
*   **User Authentication**: Secure login via Webex.
*   **Performance-focused**: Designed for speed and efficiency.

## Technologies Used

*   **Flutter**: UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Dart**: Programming language optimized for client-side development.
*   **webexapis**: A custom Flutter package for interacting with Webex APIs.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   Flutter SDK (stable channel recommended)
*   Dart SDK

### Environment Variables

This project uses environment variables for sensitive information like API keys. Create a `.env` file in the root of the project with the following content:

```
WEBEX_CLIENT_ID=your_webex_client_id
WEBEX_CLIENT_SECRET=your_webex_client_secret
```

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/webexlite.git
    cd webexlite
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

### Running the App

To run the application on a connected device or emulator:

```bash
flutter run
```

### Running Tests

To run all tests:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/widget_test.dart
```

## Project Structure

The core application logic and UI components are located in the `lib/` directory:

*   `lib/main.dart`: The entry point of the application.
*   `lib/app_shell.dart`: Defines the main application shell and navigation.
*   `lib/init.dart`: Handles application initialization tasks.
*   `lib/core/`: Contains core utilities, constants, and services.
*   `lib/custom/`: Custom widgets and navigation components.
*   `lib/screens/`: Individual feature screens (e.g., `home_page`, `messages_page`, `login_page`).
*   `lib/storage/`: Data storage and persistence logic.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file.
