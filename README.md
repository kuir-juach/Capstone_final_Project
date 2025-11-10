# **LeafSense – South Sudanese Medicinal Plant Identifier**

### Bridging Traditional Knowledge and Modern Innovation Through AI

## **Overview**

**LeafSense** is a mobile deep learning application developed to identify **South Sudanese medicinal plants** with high accuracy while preserving indigenous knowledge.  

Designed for accessibility in low-resource communities, it empowers users to capture or upload images of medicinal plants and instantly receive identification, therapeutic uses, traditional preparation methods, and cultural context.

At its core, **LeafSense** represents more than technology — it’s a movement to **preserve traditional medicine**, **promote healthcare access**, and **empower rural communities** through artificial intelligence.

## **Problem Statement**

In South Sudan, where **over 70% of the population depends on traditional medicine** due to limited access to modern healthcare, there exists a **rapid loss of indigenous medicinal knowledge**. The challenges include:

- **Loss of intergenerational knowledge** due to modernization and migration  
- **Misidentification of plants**, leading to potential poisoning or ineffective treatment  
- **Lack of written documentation** for traditional remedies  
- **Limited healthcare infrastructure**, especially in rural and low-income areas  

This situation threatens not only the **cultural heritage** of South Sudan but also **public health and biodiversity**.


## **Solution**

**LeafSense** provides an **AI-powered medicinal plant identification system** designed specifically for South Sudan’s ecosystem and community needs.

It combines **deep learning**, **traditional knowledge**, and **accessible mobile technology** to:

- Instantly identify medicinal plants through image recognition  
- Provide verified information on preparation, dosage, and usage  
- Support bilingual interfaces (English and Arabic)  
- Connect users with traditional medicine experts through online consultations  
- Work offline in remote areas with poor connectivity  

By blending **modern AI tools** with **cultural preservation**, LeafSense ensures that traditional medicinal wisdom remains accessible, safe, and relevant for future generations.
https://github.com/kuir-juach/Capstone_final_Project/blob/main/Screenshot%202025-11-09%20183436.png
## GitHub Repository
Here is the link to the GitHub https://github.com/kuir-juach/Capstone_final_Project.git 
## Link to the Video
Here is the link to the demo video https://youtu.be/0YNp_eZljXY 
## Link to the APK
Here is the link to the APK file https://drive.google.com/drive/folders/1PgLYdAGG82hL7kXi3znyo-p5VHsxejIv?usp=sharing
## **Key Features**

### **Plant Identification**
- Real-time recognition: capture or upload images for instant detection  
- High accuracy using **CNN-based MobileNetV2 model** trained on 10+ species  
- Displays **confidence score** for each prediction  

### **Comprehensive Plant Database**
- Medicinal properties, uses, and dosage guidelines  
- Traditional preparation and preservation methods  
- Safety warnings and usage notes  
- Multi-language support (English & Arabic)

### **Expert Consultation**
- Book appointments with herbal specialists  
- Integrated **Google Meet** video consultations  
- Real-time admin approval and email notifications  

### **User Experience**
- Intuitive, responsive mobile design  
- Dark/Light theme support  
- Adjustable font sizes for readability  
- Identification history tracking  

### **AI Model**
- MobileNetV2 architecture with transfer learning  
- TensorFlow & Keras implementation  
- Optimized for mobile devices (inference <2 seconds)  

### **Admin Dashboard**
- Manage users, appointments, and feedback  
- Monitor analytics and system performance  
- Approve consultations and review reports  

---

## **System Architecture**

```bash
LeafSense/
├──  Mobile App (Flutter)
│   ├── Cross-platform UI
│   ├── Camera & gallery integration
│   ├── Firebase authentication
│   └── Real-time notifications
│
├──     Backend API (FastAPI)
│   ├── TensorFlow ML model
│   ├── PostgreSQL database
│   ├── Image processing logic
│   └── RESTful API endpoints
│
├──     Admin Dashboard (HTML/JS)
│   ├── User & appointment management
│   └── Analytics and reporting
│
└──    AI Model (CNN)
    ├── MobileNetV2 architecture
    ├── Transfer learning
    └── 10-class medicinal plant classifier

## Environment Setup & Installation

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code
- Git

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/leafsense-app.git
   cd leafsense-app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure development environment**
   ```bash
   flutter doctor
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^0.8.7+5
  flutter/foundation: ^0.0.0
  flutter/services: ^0.0.0
```

### Platform Support
- Android (API 21+)
- Web (Progressive Web App)

## Design & User Interface

### App Screenshots

#### Onboarding Screens
<div align="center">
  <img src="https://github.com/kuir-juach/LeafSense_initial_Product/blob/master/Screenshot%202025-10-07%20193835.png?raw=true"/>
  <img src="https://github.com/kuir-juach/LeafSense_initial_Product/blob/master/Screenshot%202025-10-07%20193852.png?raw=true" width="250" alt="Features Screen"/>
</div>

#### Main Application
<div align="center">
  <img src="https://github.com/kuir-juach/LeafSense_initial_Product/blob/master/Screenshot%202025-10-07%20193911.png?raw=true" width="250" alt="Home Screen"/>
  <img src="https://github.com/kuir-juach/LeafSense_initial_Product/blob/master/Screenshot%202025-10-07%20195231.png?raw=true" width="250" alt="Prediction Results"/>
  <img src="https://github.com/kuir-juach/LeafSense_initial_Product/blob/master/Screenshot%202025-10-07%20200204.png?raw=true" width="250" alt="History Screen"/>
</div>

#### Settings & Accessibility
<div align="center">
  <img src="https://github.com/kuir-juach/LeafSense_initial_Product/blob/master/Screenshot%202025-10-07%20194629.png?raw=true" width="250" alt="Settings Screen"/>
  <img src="https://github.com/kuir-juach/LeafSense_initial_Product/blob/master/Screenshot%202025-10-07%20200241.png?raw=true" width="250" alt="Arabic Interface"/>
</div>

#### Machine Learning Overview
LeafSense integrates a deep learning model designed to accurately identify South Sudanese medicinal plants based on leaf images accurately. The model was trained using Convolutional Neural Networks (CNNs), optimized for mobile and offline performance through TensorFlow Lite conversion.

#### Model Architecture
#### The baseline model consists of:
-	Convolutional Layers (3 blocks): Extracts unique leaf texture and shape patterns
-	Batch Normalization: Improves stability and accelerates convergence
-	MaxPooling Layers: Reduce spatial dimensions and computation cost
-	Dropout Layer (0.4): Prevents overfitting
-	Dense Layers: Performs high-level feature interpretation
-	Softmax Output: Classifies the image into one of the known medicinal plant categories
  #### Training Configuration
-	Framework: TensorFlow / Keras
-	Optimizer: Adam (learning rate = 0.001)
-	Loss Function: Categorical Cross-Entropy
-	Metrics: Accuracy
-	Image Size: 224×224 pixels
-	Batch Size: 32
- Epochs: Configurable (commonly 30–50 depending on dataset)
  #### Dataset
- Source: Collected and labeled dataset of South Sudanese medicinal plants
- Structure:
- 70% Training
- 20% Validation
- 10% Testing
#### 	Preprocessing: Image rescaling, random rotation, flipping, zooming, and shifting for augmentation
#### Model Deployment
- The trained CNN was converted to TensorFlow Lite (.tflite) format for mobile compatibility.
- The model runs entirely offline, enabling users in remote areas to identify plants without internet access.
- Inference time is optimized to deliver results in under 2 seconds on mid-range smartphones.
  #### Performance Highlights
- High Accuracy in recognizing locally available medicinal plants
- Lightweight & Efficient for low-resource devices
- Explainable Predictions through top-3 class probability display


### Design System

#### Color Palette
- **Primary Green**: `#00652E` (RGB: 0, 101, 46)
- **Light Green**: `#F1F8E9` (Background)
- **Dark Theme**: `#121212` (Background), `#1E1E1E` (Cards)
- **Text Colors**: `#212121` (Primary), `#757575` (Secondary)

#### Typography
- **Headers**: 28px, Bold
- **Body Text**: 16px (Adjustable: 12-24px)
- **Captions**: 14px
- **Font Families**: Default, Roboto, Arial, Times New Roman, Courier New

#### Key Features
- **Dark/Light Mode Toggle**
- **Adjustable Font Sizes** (Accessibility)
- **Bilingual Interface** (English/Arabic)
- **Responsive Design** for various screen sizes


#### Hosting & Backend
- **Frontend**: Firebase Hosting (Web), App Stores (Mobile)
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics
- **Performance**: Firebase Performance Monitoring

#### Offline Capabilities
- **Local Storage**: SQLite database for plant information
- **Image Processing**: On-device TensorFlow Lite model

#### Security & Privacy
- **Data Protection**: Local data encryption
- **Permissions**: Camera access only when needed


## 📞 Contact

**Contributor**
- Email: k.thuch@alustudent.com
- Name: Kuir Thuch
