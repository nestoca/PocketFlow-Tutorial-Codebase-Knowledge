import dotenv
import os
import argparse
import yaml
# Import the function that creates the flow
from flow import create_tutorial_flow

dotenv.load_dotenv()

# Default file patterns
DEFAULT_INCLUDE_PATTERNS = {
    "*.py", "*.js", "*.jsx", "*.ts", "*.tsx", "*.go", "*.java", "*.pyi", "*.pyx",
    "*.c", "*.cc", "*.cpp", "*.h", "*.md", "*.rst", "*Dockerfile",
    "*Makefile", "*.yaml", "*.yml",
}

DEFAULT_EXCLUDE_PATTERNS = {
    "assets/*", "data/*", "images/*", "public/*", "static/*", "temp/*",
    "*docs/*",
    "*venv/*",
    "*.venv/*",
    "*test*",
    "*tests/*",
    "*examples/*",
    "v1/*",
    "*dist/*",
    "*build/*",
    "*experimental/*",
    "*deprecated/*",
    "*misc/*",
    "*legacy/*",
    ".git/*", ".github/*", ".next/*", ".vscode/*",
    "*obj/*",
    "*bin/*",
    "*node_modules/*",
    "*.log"
}

def load_config(config_path):
    """Load and validate YAML configuration file."""
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
        
        # Validate required sections
        required_sections = ['source', 'project']
        for section in required_sections:
            if section not in config:
                raise ValueError(f"Missing required section '{section}' in config file")
        
        # Validate source (must have either repo or local_dir)
        source = config['source']
        if not ('repo' in source or 'local_dir' in source):
            raise ValueError("Source section must contain either 'repo' or 'local_dir'")
        
        # Set defaults for optional sections
        if 'file_processing' not in config:
            config['file_processing'] = {}
        if 'analysis' not in config:
            config['analysis'] = {}
        if 'llm' not in config:
            config['llm'] = {}
        if 'github' not in config:
            config['github'] = {}
            
        return config
        
    except FileNotFoundError:
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    except yaml.YAMLError as e:
        raise ValueError(f"Invalid YAML in configuration file: {e}")
    except Exception as e:
        raise Exception(f"Error loading configuration: {e}")

def config_to_shared(config):
    """Convert YAML config to shared dictionary format."""
    source = config['source']
    project = config['project']
    file_proc = config.get('file_processing', {})
    analysis = config.get('analysis', {})
    llm_config = config.get('llm', {})
    github_config = config.get('github', {})
    
    # Get GitHub token from config or environment variable
    github_token = None
    if 'repo' in source:
        github_token = github_config.get('token') or os.environ.get('GITHUB_TOKEN')
        if not github_token:
            print("Warning: No GitHub token provided. You might hit rate limits for public repositories.")
    
    # Load feedback from file if provided
    feedback_content = None
    feedback_file = analysis.get('feedback_file')
    if feedback_file:
        try:
            with open(feedback_file, 'r', encoding='utf-8') as f:
                feedback_content = f.read()
            print(f"Loaded feedback from: {feedback_file}")
        except FileNotFoundError:
            print(f"Warning: Feedback file not found: {feedback_file}")
        except Exception as e:
            print(f"Warning: Could not read feedback file {feedback_file}: {e}")
    
    # Get abstractions hints and calculate max abstractions
    abstractions_hints = analysis.get('abstractions_hints')
    max_abstractions = analysis.get('max_abstractions', 10)
    
    # Ensure abstractions_hints is never None, default to empty list
    if abstractions_hints is None:
        abstractions_hints = []
    
    # If specific abstractions are provided, use their count as max
    if abstractions_hints:
        max_abstractions = len(abstractions_hints)
        print(f"✓ Using {len(abstractions_hints)} specific abstraction hints")
    else:
        print(f"✓ No specific abstraction hints provided, will identify up to {max_abstractions} abstractions")
    
    shared = {
        "repo_url": source.get('repo'),
        "local_dir": source.get('local_dir'),
        "project_name": project.get('name'),
        "github_token": github_token,
        "output_dir": project.get('output_dir', 'output'),

        # File processing settings
        "include_patterns": set(file_proc.get('include_patterns', DEFAULT_INCLUDE_PATTERNS)),
        "exclude_patterns": set(file_proc.get('exclude_patterns', DEFAULT_EXCLUDE_PATTERNS)),
        "max_file_size": file_proc.get('max_file_size', 100000),

        # Project settings
        "language": project.get('language', 'english'),
        
        # LLM settings
        "use_cache": llm_config.get('use_cache', True),
        
        # Analysis settings
        "abstractions_hints": abstractions_hints,
        "max_abstraction_num": max_abstractions,
        "feedback_content": feedback_content,

        # Outputs will be populated by the nodes
        "files": [],
        "abstractions": [],
        "relationships": {},
        "chapter_order": [],
        "chapters": [],
        "final_output_dir": None
    }
    
    return shared

# --- Main Function ---
def main():
    parser = argparse.ArgumentParser(description="Generate a tutorial for a GitHub codebase or local directory using YAML configuration.")
    parser.add_argument("config", help="Path to YAML configuration file")
    parser.add_argument("--validate-only", action="store_true", help="Only validate the configuration file without running the analysis")
    
    args = parser.parse_args()
    
    try:
        # Load and validate configuration
        config = load_config(args.config)
        print(f"✓ Configuration loaded successfully from: {args.config}")
        
        if args.validate_only:
            print("✓ Configuration is valid!")
            return
        
        # Convert config to shared dictionary
        shared = config_to_shared(config)
        
        # Display starting message
        source_info = shared.get('repo_url') or shared.get('local_dir')
        language = shared.get('language', 'english')
        print(f"🚀 Starting tutorial generation for: {source_info} in {language.capitalize()} language")
        print(f"📊 Configuration:")
        print(f"   ├─ Project name: {shared.get('project_name', 'Auto-detected')}")
        print(f"   ├─ Output directory: {shared.get('output_dir')}")
        print(f"   ├─ Max file size: {shared.get('max_file_size'):,} bytes")
        print(f"   ├─ LLM caching: {'Enabled' if shared.get('use_cache') else 'Disabled'}")
        print(f"   ├─ Language: {language.capitalize()}")
        print(f"   └─ Feedback from previous run: {'Yes' if shared.get('feedback_content') else 'No'}")
        
        include_count = len(shared.get('include_patterns', []))
        exclude_count = len(shared.get('exclude_patterns', []))
        print(f"📁 File patterns: {include_count} include, {exclude_count} exclude")
        
        # Create the flow instance
        tutorial_flow = create_tutorial_flow()
        
        # Run the flow
        tutorial_flow.run(shared)
        
    except Exception as e:
        print(f"Error: {e}")
        exit(1)

if __name__ == "__main__":
    main()
