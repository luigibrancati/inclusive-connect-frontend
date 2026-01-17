import firebase_admin
from firebase_admin import credentials, storage, firestore, auth
import os
import re
import json

# CONFIGURATION
# Ensure you have your serviceAccountKey.json in this directory or update the path below.
SERVICE_ACCOUNT_FILE = 'serviceAccountKey.json'
STORAGE_BUCKET = 'inclusiveconnect-b47e2.firebasestorage.app'

def upload_test_data_images():
    # Detect the directory where this script  is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Path to service account key
    sa_path = os.path.join(script_dir, SERVICE_ACCOUNT_FILE)
    
    if not os.path.exists(sa_path):
        print(f"Error: Service account key not found at {sa_path}")
        print("Please place your 'serviceAccountKey.json' in the same directory as this script.")
        return

    # Initialize Firebase Admin
    try:
        cred = credentials.Certificate(sa_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': STORAGE_BUCKET
        })
    except ValueError:
        # App already initialized
        pass

    bucket = storage.bucket()
    
    # Path to data/pics relative to this script
    base_data_dir = os.path.join(script_dir, 'data', 'pics')

    if not os.path.exists(base_data_dir):
        print(f"Directory not found: {base_data_dir}")
        return

    def upload_from_dir(sub_dir_name, remote_prefix, id_prefix):
        dir_path = os.path.join(base_data_dir, sub_dir_name)
        if not os.path.exists(dir_path):
            print(f"Sub-directory not found: {dir_path}")
            return

        print(f"Scanning {sub_dir_name}...")

        # Regex to match folder names like user_123 or user-123
        pattern = re.compile(rf"{id_prefix}[-_](\d+)")

        for item in os.listdir(dir_path):
            item_path = os.path.join(dir_path, item)
            
            if os.path.isdir(item_path):
                # Check if folder name matches the pattern
                match = pattern.search(item)
                if match:
                    entity_id = match.group(1)
                    
                    # List all files in the directory
                    all_files = [f for f in os.listdir(item_path) if os.path.isfile(os.path.join(item_path, f))]
                    # Filter for likely image files if needed, but we'll take all files as per request
                    # Sort to ensure deterministic order (image-1, image-2...)
                    all_files.sort()

                    if not all_files:
                        continue

                    if len(all_files) == 1:
                        # Single image -> filename 'image' (no extension in remote path, but content type matters)
                        file_name = all_files[0]
                        local_file = os.path.join(item_path, file_name)
                        
                        # Remote path: prefix/id-prefix-id/image
                        # Example: profile-pics/user-1/image
                        blob_path = f"{remote_prefix}/{id_prefix}-{entity_id}/image"
                        
                        blob = bucket.blob(blob_path)
                        # Optional: set content type explicitly if needed, e.g. based on extension
                        blob.upload_from_filename(local_file)
                        print(f"Uploaded: {blob_path}")

                    else:
                        # Multiple images -> image-1, image-2...
                        for i, file_name in enumerate(all_files):
                            index = i + 1
                            local_file = os.path.join(item_path, file_name)
                            
                            # Remote path: prefix/id-prefix-id/image-N
                            blob_path = f"{remote_prefix}/{id_prefix}-{entity_id}/image-{index}"
                            
                            blob = bucket.blob(blob_path)
                            blob.upload_from_filename(local_file)
                            print(f"Uploaded: {blob_path}")

    # 1. Profile Pics
    # Folder: data/pics/profile_pics/user-<id>
    # Remote: profile-pics/user-<id>/image
    upload_from_dir('profile_pics', 'profile-pics', 'user')

    # 2. Post Images
    # Folder: data/pics/post_images/post-<id>
    # Remote: post-images/post-<id>/image (or image-n)
    upload_from_dir('post_images', 'post-images', 'post')

    print("Image upload complete.")

def upload_test_data_firestore():
    # Detect the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Path to service account key
    sa_path = os.path.join(script_dir, SERVICE_ACCOUNT_FILE)
    
    if not os.path.exists(sa_path):
        print(f"Error: Service account key not found at {sa_path}")
        return

    # Initialize Firebase Admin (if not already)
    try:
        cred = credentials.Certificate(sa_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': STORAGE_BUCKET
        })
    except ValueError:
        pass

    db = firestore.client()
    base_data_dir = os.path.join(script_dir, 'data', 'database')

    if not os.path.exists(base_data_dir):
        print(f"Database data directory not found: {base_data_dir}")
        return

    # Helper to commit batches
    def commit_batch(collection_name, items, id_field):
        batch = db.batch()
        ops = 0
        total = 0
        print(f"Importing {len(items)} items into '{collection_name}'...")
        
        for item in items:
            item_id = str(item.get(id_field, db.collection(collection_name).document().id))
            doc_ref = db.collection(collection_name).document(item_id)
            batch.set(doc_ref, item)
            ops += 1
            total += 1
            
            if ops >= 400:
                batch.commit()
                batch = db.batch()
                ops = 0
                print(f"  Committed {total} items...")
        
        if ops > 0:
            batch.commit()
            print(f"  Committed final batch. Total: {total}")

    # Load JSON files
    def load_json(filename):
        path = os.path.join(base_data_dir, filename)
        if not os.path.exists(path):
            print(f"File not found: {filename}")
            return []
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)

    # 1. Users
    users = load_json('users.json')
    # Create Auth users first (optional, mirrors Dart logic)
    for u in users:
        email = u.get('email')
        uid = u.get('userId') # Assuming userId maps to UID
        if email:
            try:
                # Check if user exists
                try:
                    auth.get_user_by_email(email)
                    # print(f"User {email} already exists.")
                except auth.UserNotFoundError:
                    # Create user
                    auth.create_user(
                        uid=str(uid) if uid else None,
                        email=email,
                        password='123456',
                    )
                    print(f"Created Auth user: {email}")
            except Exception as e:
                print(f"Error creating user {email}: {e}")
                
    commit_batch('users', users, 'userId')

    # 2. Posts
    posts = load_json('posts.json')
    commit_batch('posts', posts, 'id')

    # 3. Invite Codes
    invites = load_json('inviteCodes.json')
    commit_batch('inviteCodes', invites, 'code')

    # 4. Notifications
    notifications = load_json('notifications.json')
    commit_batch('notifications', notifications, 'id')

    # 5. Relationships
    relationships = load_json('relationships.json')
    # Special handling for relationships to generate ID
    # Sort participants to ensure consistent ID: user1_user2
    rel_batch = db.batch()
    rel_ops = 0
    print(f"Importing {len(relationships)} relationships...")
    
    for rel in relationships:
        participants = rel.get('participants', [])
        if len(participants) == 2:
            p1 = str(participants[0])
            p2 = str(participants[1])
            # Determine ID deterministically (alphabetical sort or existing logic)
            # Dart logic: relationshipService.getDocId(p1, p2)
            # Usually: sort and join with '_'
            sorted_p = sorted([p1, p2])
            doc_id = f"{sorted_p[0]}_{sorted_p[1]}"
            
            doc_ref = db.collection('relationships').document(doc_id)
            rel_batch.set(doc_ref, rel)
            rel_ops += 1
            if rel_ops >= 400:
                rel_batch.commit()
                rel_batch = db.batch()
                rel_ops = 0

    if rel_ops > 0:
        rel_batch.commit()
    print("Relationships imported.")

    print("Firestore import complete.")

if __name__ == "__main__":
    upload_test_data_images()
    upload_test_data_firestore()
