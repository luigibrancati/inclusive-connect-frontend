# Development Environment Data & Tools

This folder contains test data and scripts for populating the development environment.

## Python Data Uploader (`upload_images.py`)

This script uploads images from `data/pics/` to Firebase Storage.

### Prerequisites

1.  **Python 3** installed.
2.  **Firebase Admin SDK**:
    ```bash
    pip install firebase-admin
    ```
3.  **Service Account Key**:
    You must provide a `serviceAccountKey.json` file in this directory to authenticate.
    
    **How to generate:**
    1.  Go to [Firebase Console](https://console.firebase.google.com/) > Project Settings > Service accounts.
    2.  Click **Generate new private key**.
    3.  Save the file as `dev_env/serviceAccountKey.json`.

    > **WARNING:** Never commit `serviceAccountKey.json` to version control. It grants administrative access to your Firebase project.

### Usage

Run the script from the project root or the `dev_env` directory:

```bash
python3 dev_env/upload_images.py
```
