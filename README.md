# Unichat Project
UniChat is a transformative platform designed to revolutionize the research experience for students and educators. It leverages the power of artificial intelligence (AI) to facilitate seamless collaboration on projects, provide efficient monitoring tools for teachers, and enhance the overall learning process.

* For Mobile: https://webapp.diawi.com/install/CG1xE6 (FOR ANDROID)
* For Web: https://unichat-barbellcoders.vercel.app/
* For database which is common between the Web team and Flutter App team : mongodb+srv://unichat_admin:j5DyBXwyCEIEk8Df@studentdata.twgkxcq.mongodb.net/?retryWrites=true&w=majority&appName=StudentData

<img width="597" alt="Screenshot 2024-05-08 at 3 35 50 PM" src="https://github.com/Jainish-shah/UniChat_2.0/assets/47889375/76712602-b0fb-4147-90e0-e24d7ec3ca25">

## Getting Started

UniChat integrates services like Discord for messaging, Google Docs for document management, and OpenAI's ChatGPT for AI-driven interaction, providing a unified interface that enhances academic collaboration and productivity.

## Seamless Collaboration

- Real-time chat system for students to exchange ideas and work together on projects.
- Group chat functionality for focused communication within specific teams.
- Knowledge Forum integration for easy transfer of relevant information.

## AI Integration

- ChatGPT integration allows students to ask questions, seek clarification, and engage in meaningful conversations related to their studies.

## Project Management

- Intuitive interface for educators to create and manage projects for their classes.
- Easy integration of Google Docs for collaborative document creation and editing.
- Monitoring tools for educators to track student progress and identify areas requiring support.

## How to Use 

**Step 1:**

Download the App or clone this repo by using the link below:

```
https://github.com/Jainish-shah/UniChat_2.0/edit/master
```

**Step 2:**

Go to project root and execute the following command in console to get the required dependencies: 

```
flutter pub get 
```

## Unichat Features:

* Splash Screen
* OnBoarding Page
* Shared Preference
* Login Page
* School Registration
* Instructor Portal Redirect
* Home Page for student with the Projects Listing
* Sidebar for multiple options for students
* Discord for project channel
* Class Announcement / Broadcasting messages
* Google Drive integration
* Native chat
* Routing
* Theme
* Google Docs for saving the chatgpt messages
* Database - MongoDB
* ChatGPT integration for AI assistant
* Provider (State Management)
* Validation by Google Sign IN

### Libraries & Tools Used

```
  google_fonts: ^6.2.0
  flutter_svg: ^2.0.10+1
  http: ^1.0.0
  mongo_dart: ^0.10.0
  webview_flutter: ^3.0.0
  url_launcher: ^6.0.20
  shared_preferences: ^2.0.15
  cupertino_icons: ^1.0.2
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.8
  firebase_ui_auth: ^1.13.1
  flutter_secure_storage: ^9.0.0
  googleapis: ^12.0.1
  path_provider: ^2.0.8
  google_sign_in: ^6.2.1
  googleapis_auth: ^1.0.0
  googledrivehandler: ^1.0.7
  open_file: ^3.3.2
  flutter_launcher_icons: ^0.12.0
  flutter_pdfview: ^1.2.1
  cloud_firestore: ^4.15.8
  firebase_database: ^10.4.5
  flutter_inappwebview: ^5.3.2
  flutter_spinkit: ^5.1.0
  flutter_dotenv: ^5.0.2
  fluttertoast: ^8.2.5
  flutter_file_downloader: ^1.2.1
  animated_text_kit: ^4.2.2
  image_picker: ^0.8.5+3
  flutter_easyloading: ^3.0.5
  flutter_file_dialog: ^3.0.2
  docx_template: ^0.4.0
```

### Folder Structure
Here is the core folder structure which flutter provides.

```
UniChat 2.0
├── .dart_tool
├── .idea
├── android
├── api
├── assets
├── build
├── ios
├── lib
│   ├── chat_gpt
│   │   └── constants
│   │       ├── api_consts.dart
│   │       └── constant.dart
│   ├── models
│   ├── provider
│   ├── screens
│   │   ├── authContexts.dart
│   │   ├── chat_page.dart
│   │   ├── chat_page2.dart
│   │   ├── discord.dart
│   │   ├── DriveFile.dart
│   │   ├── firebase_options.dart
│   │   ├── google_drive.dart
│   │   ├── home_navbar.dart
│   │   ├── home_page.dart
│   │   ├── instructor_login_page.dart
│   │   ├── login_page.dart
│   │   ├── loginform.dart
│   │   ├── main.dart
│   │   ├── main_home_page.dart
│   │   ├── MultiLayerParallax.dart
│   │   ├── navbar.dart
│   │   ├── onboarding_page.dart
│   │   ├── profile_page.dart
│   │   ├── project_chat_history.dart
│   │   ├── project_listing.dart
│   │   ├── project_wise_student_list_screen.dart
│   │   ├── RegistrationForm.dart
│   │   ├── RegistrationSuccessPage.dart
│   │   ├── school_registration_page.dart
│   │   ├── schoolModel.js
│   │   ├── show_projects.dart
│   │   ├── sidebar.dart
│   │   └── splash_page.dart
│   ├── services
│   └── widgets
├── linux
├── macos
├── node_modules
├── test
├── windows
├── .flutter-plugins
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── package.json
├── package-lock.json
├── pubspec.lock
├── pubspec.yaml
└── README.md
```
