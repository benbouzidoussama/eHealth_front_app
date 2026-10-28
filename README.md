# 🏥 E-Health — Application Mobile de Santé

**E-Health** est une application mobile développée avec Flutter qui vise à faciliter la communication et le suivi médical entre les patients et les médecins. Elle permet de simplifier la gestion des rendez-vous, de centraliser les informations médicales et d'améliorer l'accès aux services de santé.

## 📌 Table des matières

- [Présentation du projet](#-présentation-du-projet)
- [Fonctionnalités](#-fonctionnalités)
- [Technologies utilisées](#-technologies-utilisées)
- [Architecture du projet](#-architecture-du-projet)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Lancement de l'application](#-lancement-de-lapplication)
- [Auteur](#-auteur)

## 🎯 Présentation du projet

E-Health est une application mobile conçue pour moderniser la relation entre le patient et le médecin grâce aux technologies numériques.

Elle s'inscrit dans une approche de **santé numérique (e-santé)** en proposant des outils de communication, de gestion des rendez-vous et de consultation des informations médicales.

Le projet utilise Flutter pour le développement de l'interface mobile et un backend Node.js avec Express et MongoDB pour la gestion des données et des fonctionnalités métier.

## ✨ Fonctionnalités

### 👤 Gestion des utilisateurs
- Authentification et gestion des comptes.
- Gestion des profils des patients et des médecins.
- Gestion des rôles et des autorisations.
- Réinitialisation du mot de passe.

### 📅 Gestion des rendez-vous
- Demande de rendez-vous médicaux.
- Consultation et suivi des rendez-vous.
- Annulation ou modification des rendez-vous.
- Gestion des disponibilités des médecins.

### 🩺 Dossier médical
- Consultation des informations médicales.
- Accès aux prescriptions et aux documents médicaux.
- Consultation des notes et des recommandations médicales.

### 💬 Communication
- Messagerie entre patients et médecins.
- Échange de messages liés au suivi médical.
- Notifications relatives aux activités de l'application.

### 💊 Suivi médical
- Consultation des prescriptions.
- Accès aux recommandations alimentaires.
- Rappels et suivi des traitements selon les fonctionnalités configurées.

### 📰 Informations médicales
- Consultation d'articles de santé.
- Accès aux documents et aux informations médicales.
- Assistant conversationnel destiné à orienter les utilisateurs vers la spécialité médicale appropriée.

## 🛠️ Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Flutter | Développement de l'application mobile |
| Dart | Langage de programmation mobile |
| Node.js | Environnement backend |
| Express.js | Développement de l'API REST |
| MongoDB | Base de données NoSQL |
| Mongoose | Modélisation des données |
| JWT | Authentification par jetons |
| Socket.IO | Communication en temps réel |
| Cloudinary | Stockage et gestion des fichiers |
| Git & GitHub | Gestion de versions et hébergement du code |

## 🏗️ Architecture du projet

Le système repose sur une architecture client-serveur.

```text
E-Health
│
├── Mobile Application
│   └── Flutter / Dart
│       ├── User Interface
│       ├── Authentication
│       ├── Appointments
│       ├── Medical Records
│       ├── Messaging
│       └── Notifications
│
└── Backend
    ├── Node.js
    ├── Express.js
    ├── MongoDB
    ├── JWT Authentication
    └── Socket.IO
```

L'application mobile communique avec le backend via des requêtes HTTP. Les fonctionnalités de communication en temps réel utilisent Socket.IO lorsque cela est configuré.

## ⚙️ Installation

### Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Git](https://git-scm.com/)
- [Visual Studio Code](https://code.visualstudio.com/) ou Android Studio
- Un émulateur Android ou un appareil Android physique

### 1. Cloner le dépôt

```bash
git clone https://github.com/benbouzidoussama/eHealth_front_app.git
```

### 2. Accéder au projet

```bash
cd eHealth_front_app
```

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Vérifier l'environnement Flutter

```bash
flutter doctor
```

Cette commande permet de vérifier la configuration de Flutter et de détecter les éventuels problèmes d'installation.

## 🔧 Configuration

Avant d'utiliser l'application, vérifiez les paramètres de connexion au backend.

1. Configurez l'URL de l'API selon l'adresse du serveur backend.
2. Vérifiez la configuration de l'authentification et des connexions réseau.
3. Assurez-vous que le backend et MongoDB sont correctement configurés et accessibles.

**Important :** sur un émulateur ou un appareil physique, l'adresse utilisée pour joindre le backend peut être différente de `localhost`. Utilisez l'adresse réseau adaptée à votre environnement de développement.

Ne publiez jamais vos mots de passe, clés API, jetons d'accès ou autres informations confidentielles dans le dépôt GitHub.

## 🚀 Lancement de l'application

Après l'installation et la configuration :

```bash
flutter run
```

Pour consulter les appareils disponibles :

```bash
flutter devices
```

Pour générer un APK Android :

```bash
flutter build apk --release
```

Le fichier APK généré se trouve généralement dans :

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 🔒 Sécurité et confidentialité

E-Health manipule des informations liées à la santé. Il est donc important de :

- Protéger les données personnelles et médicales des utilisateurs.
- Sécuriser les échanges entre l'application mobile et le backend.
- Appliquer des contrôles d'accès selon les rôles.
- Ne pas exposer les informations confidentielles dans les journaux ou le dépôt public.
- Tester les mécanismes d'authentification et les autorisations avant tout déploiement.

## 👨‍💻 Auteur

**Oussama Ben Bouzid**

- GitHub : [@benbouzidoussama](https://github.com/benbouzidoussama)
- Projet : [eHealth_front_app](https://github.com/benbouzidoussama/eHealth_front_app)

---

*E-Health — Mettre la technologie au service de la santé.*
