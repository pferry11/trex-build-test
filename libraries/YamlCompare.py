import yaml

class YamlCompare:
    def load_yaml(self, text):
        return yaml.safe_load(text)
