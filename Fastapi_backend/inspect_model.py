import h5py
import json

def inspect_model(model_path):
    """Inspect H5 model file structure"""
    print(f"Inspecting model: {model_path}")
    
    with h5py.File(model_path, 'r') as f:
        print("\n=== H5 File Structure ===")
        
        def print_structure(name, obj):
            print(f"{name}: {type(obj)}")
            if hasattr(obj, 'attrs'):
                for attr_name, attr_val in obj.attrs.items():
                    if isinstance(attr_val, bytes):
                        try:
                            attr_val = attr_val.decode('utf-8')
                        except:
                            attr_val = str(attr_val)
                    print(f"  {attr_name}: {attr_val}")
        
        f.visititems(print_structure)
        
        # Check for model config
        if 'model_config' in f.attrs:
            config = f.attrs['model_config']
            if isinstance(config, bytes):
                config = config.decode('utf-8')
            print(f"\n=== Model Config ===")
            try:
                config_json = json.loads(config)
                print(json.dumps(config_json, indent=2))
            except:
                print(config)
        
        # Check for keras version
        if 'keras_version' in f.attrs:
            keras_version = f.attrs['keras_version']
            if isinstance(keras_version, bytes):
                keras_version = keras_version.decode('utf-8')
            print(f"\n=== Keras Version ===")
            print(keras_version)
        
        # Check for backend
        if 'backend' in f.attrs:
            backend = f.attrs['backend']
            if isinstance(backend, bytes):
                backend = backend.decode('utf-8')
            print(f"\n=== Backend ===")
            print(backend)

if __name__ == "__main__":
    inspect_model("Medicinal_model.h5")