import tensorflow as tf
import os

# Disable warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

def convert_h5_to_savedmodel():
    """Convert H5 model to SavedModel format with compatibility fixes"""
    
    # Custom objects for loading
    def custom_input_layer(**config):
        if 'batch_shape' in config:
            config['input_shape'] = config.pop('batch_shape')[1:]
        return tf.keras.layers.InputLayer(**config)
    
    def custom_dtype_policy(**config):
        return tf.keras.mixed_precision.Policy(config.get('name', 'float32'))
    
    custom_objects = {
        'InputLayer': custom_input_layer,
        'DTypePolicy': custom_dtype_policy
    }
    
    try:
        # Load with custom objects and safe_mode=False
        model = tf.keras.models.load_model(
            'Medicinal_model.h5', 
            custom_objects=custom_objects,
            compile=False,
            safe_mode=False
        )
        
        # Save as SavedModel format
        model.save('medicinal_savedmodel', save_format='tf')
        print("✅ Model converted to SavedModel format")
        
        # Test the model
        import numpy as np
        test_input = np.random.random((1, 256, 256, 3)).astype(np.float32)
        predictions = model.predict(test_input, verbose=0)
        print(f"Test prediction shape: {predictions.shape}")
        print(f"Test prediction sum: {predictions.sum()}")
        
        return True
        
    except Exception as e:
        print(f"❌ Conversion failed: {e}")
        return False

if __name__ == "__main__":
    convert_h5_to_savedmodel()