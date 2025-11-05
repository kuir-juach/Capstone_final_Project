import tensorflow as tf
import numpy as np
from PIL import Image
import os

def test_model():
    """Test if the model loads and works correctly"""
    
    MODEL_PATH = "Medicinal_model.h5"
    
    if not os.path.exists(MODEL_PATH):
        print("❌ Model file not found!")
        return False
    
    try:
        # Load model
        model = tf.keras.models.load_model(MODEL_PATH, compile=False)
        print("✅ Model loaded successfully")
        print(f"Input shape: {model.input_shape}")
        print(f"Output shape: {model.output_shape}")
        
        # Test with dummy image
        dummy_image = np.random.rand(1, 256, 256, 3).astype(np.float32)
        predictions = model.predict(dummy_image, verbose=0)
        
        print(f"✅ Prediction successful")
        print(f"Prediction shape: {predictions.shape}")
        print(f"Prediction values: {predictions[0]}")
        
        # Check if predictions sum to 1 (softmax)
        pred_sum = np.sum(predictions[0])
        print(f"Prediction sum: {pred_sum:.4f}")
        
        if abs(pred_sum - 1.0) < 0.001:
            print("✅ Model predictions are properly normalized")
        else:
            print("⚠️ Model predictions may not be properly normalized")
        
        return True
        
    except Exception as e:
        print(f"❌ Model test failed: {e}")
        return False

if __name__ == "__main__":
    test_model()