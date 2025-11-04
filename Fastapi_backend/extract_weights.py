import h5py
import numpy as np
import pickle

def extract_weights_from_h5(model_path):
    """Extract weights from H5 model file"""
    weights_dict = {}
    
    with h5py.File(model_path, 'r') as f:
        # Navigate to model weights
        if 'model_weights' in f:
            model_weights = f['model_weights']
            
            def extract_layer_weights(name, obj):
                if isinstance(obj, h5py.Group):
                    layer_weights = {}
                    for key in obj.keys():
                        if isinstance(obj[key], h5py.Dataset):
                            layer_weights[key] = np.array(obj[key])
                    if layer_weights:
                        weights_dict[name] = layer_weights
            
            model_weights.visititems(extract_layer_weights)
    
    # Save weights as pickle for easy loading
    with open('extracted_weights.pkl', 'wb') as f:
        pickle.dump(weights_dict, f)
    
    print(f"Extracted weights for {len(weights_dict)} layers")
    for layer_name in weights_dict.keys():
        print(f"  - {layer_name}")
    
    return weights_dict

if __name__ == "__main__":
    extract_weights_from_h5("Medicinal_model.h5")