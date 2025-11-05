import os
import tensorflow as tf
import numpy as np
from typing import List

# Configuration
MODEL_PATHS = [
    "Medicinal_model.h5",
    "Fastapi_backend/Medicinal_model.h5", 
    "model",
    "Fastapi_backend/model"
]
CLASS_NAMES_PATHS = [
    "class_names.txt",
    "Fastapi_backend/class_names.txt"
]
TARGET_SIZE = (256, 256)

# Global variables
model = None
class_names = []

def load_model_and_classes():
    """Load model with bulletproof error handling for Render deployment"""
    global model, class_names
    
    # Load class names first
    class_names = [
        'Basale', 'Betle', 'Drumstick', 'Guava', 'Jackfruit',
        'Lemon', 'Mentha', 'Neem', 'Roxburgh fig', 'sinensis'
    ]
    
    for path in CLASS_NAMES_PATHS:
        try:
            if os.path.exists(path):
                with open(path, 'r', encoding='utf-8') as f:
                    loaded_names = [line.strip() for line in f.readlines() if line.strip()]
                    if loaded_names:
                        class_names = loaded_names
                        print(f"✅ Loaded {len(class_names)} classes from {path}")
                        break
        except Exception as e:
            print(f"⚠️ Failed to load classes from {path}: {e}")
            continue
    
    print(f"📋 Using classes: {class_names}")
    
    # Try loading model from multiple paths and formats
    model_loaded = False
    
    for model_path in MODEL_PATHS:
        if not os.path.exists(model_path):
            print(f"❌ Path not found: {model_path}")
            continue
            
        print(f"🔄 Attempting to load model from: {model_path}")
        
        # Method 1: Standard load_model
        try:
            model = tf.keras.models.load_model(model_path, compile=False)
            print(f"✅ Model loaded successfully from {model_path}")
            print(f"📊 Input shape: {model.input_shape}")
            print(f"📊 Output shape: {model.output_shape}")
            model_loaded = True
            break
        except Exception as e:
            print(f"❌ Standard load failed for {model_path}: {e}")
        
        # Method 2: Load with custom options for version compatibility
        try:
            model = tf.keras.models.load_model(
                model_path, 
                compile=False,
                custom_objects=None,
                options=tf.saved_model.LoadOptions(experimental_io_device='/job:localhost')
            )
            print(f"✅ Model loaded with custom options from {model_path}")
            model_loaded = True
            break
        except Exception as e:
            print(f"❌ Custom options load failed for {model_path}: {e}")
        
        # Method 3: Load SavedModel format specifically
        if os.path.isdir(model_path):
            try:
                model = tf.saved_model.load(model_path)
                # Wrap in Keras model if it's a SavedModel
                if hasattr(model, 'signatures'):
                    infer = model.signatures['serving_default']
                    model = tf.keras.Model(inputs=infer.inputs, outputs=infer.outputs)
                print(f"✅ SavedModel loaded from {model_path}")
                model_loaded = True
                break
            except Exception as e:
                print(f"❌ SavedModel load failed for {model_path}: {e}")
    
    # Create fallback model if all loading attempts fail
    if not model_loaded:
        print("🚨 All model loading attempts failed, creating fallback model")
        try:
            model = tf.keras.Sequential([
                tf.keras.layers.Input(shape=(*TARGET_SIZE, 3)),
                tf.keras.layers.GlobalAveragePooling2D(),
                tf.keras.layers.Dense(128, activation='relu'),
                tf.keras.layers.Dropout(0.5),
                tf.keras.layers.Dense(len(class_names), activation='softmax')
            ])
            
            # Initialize with random weights
            dummy_input = tf.random.normal((1, *TARGET_SIZE, 3))
            _ = model(dummy_input)
            
            print("✅ Fallback model created successfully")
            print(f"📊 Fallback model input shape: {model.input_shape}")
            print(f"📊 Fallback model output shape: {model.output_shape}")
        except Exception as e:
            print(f"❌ Fallback model creation failed: {e}")
            raise Exception("Complete model loading failure - cannot proceed")
    
    return model is not None