import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf
import numpy as np

# Test model loading
try:
    print("Loading model...")
    model = tf.keras.models.load_model("Medicinal_model.h5", compile=False)
    print(f"Model loaded successfully!")
    print(f"Input shape: {model.input_shape}")
    print(f"Output shape: {model.output_shape}")
    
    # Test prediction with dummy data
    dummy_input = np.random.rand(1, 256, 256, 3).astype(np.float32)
    predictions = model.predict(dummy_input, verbose=0)
    print(f"Prediction shape: {predictions.shape}")
    print(f"Sample prediction: {predictions[0][:5]}")  # First 5 values
    
    predicted_index = np.argmax(predictions[0])
    confidence = float(predictions[0][predicted_index])
    print(f"Predicted index: {predicted_index}")
    print(f"Confidence: {confidence}")
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()