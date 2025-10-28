# Docker Usage Guide

This guide explains how to build, push, and run the PocketFlow Tutorial application using Docker and the provided Makefile.

## Quick Start

1. **Build the Docker image:**
   ```bash
   make build
   ```

2. **Run with a configuration file:**
   ```bash
   make run CONFIG_FILE=configs/example_config.yaml
   ```

3. **Validate configuration without running:**
   ```bash
   make validate CONFIG_FILE=configs/my_config.yaml
   ```

## Configuration

The Makefile supports several configurable variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `IMAGE_NAME` | `pocketflow-tutorial` | Docker image name |
| `IMAGE_TAG` | `latest` | Docker image tag |
| `REGISTRY` | `docker.io` | Docker registry URL |
| `REGISTRY_USER` | `your-username` | Registry username |
| `CONFIG_FILE` | `configs/example_config.yaml` | Path to YAML config file |
| `OUTPUT_DIR` | `./output` | Local output directory |
| `MOUNT_DIR` | `./mount` | Local directory to mount for source code |

## Available Commands

### Build Commands
- `make build` - Build the Docker image
- `make build-dev` - Build with development target
- `make push` - Build and push to registry
- `make tag-and-push VERSION=1.0.0` - Tag with version and push

### Run Commands
- `make run` - Run with config file
- `make run-local` - Run with local directory mounting
- `make run-debug` - Run in debug mode with interactive shell
- `make shell` - Open interactive shell in container

### Utility Commands
- `make validate` - Validate configuration file
- `make clean` - Clean up Docker resources
- `make lint` - Run code quality checks
- `make test` - Run tests
- `make logs` - Show container logs
- `make help` - Show help message

## Usage Examples

### Basic Usage
```bash
# Build and run with default config
make build
make run

# Use custom configuration
make run CONFIG_FILE=configs/corebanking.yaml

# Validate configuration before running
make validate CONFIG_FILE=configs/my_config.yaml
```

### Working with Local Directories
```bash
# Mount a local source directory
make run-local CONFIG_FILE=configs/my_config.yaml MOUNT_DIR=/path/to/source/code

# The mounted directory will be available at /app/mount inside the container
```

### Registry Operations
```bash
# Push to Docker Hub
make push REGISTRY_USER=myusername

# Push to a different registry
make push REGISTRY=ghcr.io REGISTRY_USER=myusername

# Tag and push a specific version
make tag-and-push VERSION=1.2.3 REGISTRY_USER=myusername
```

### Development Workflow
```bash
# Development setup
make dev

# Debug a configuration issue
make run-debug CONFIG_FILE=configs/problematic.yaml

# Check logs from the last run
make logs

# Clean up when done
make clean
```

## File Mounting

The Makefile automatically mounts several directories:

1. **Configuration file**: Mounted as read-only at `/app/config.yaml`
2. **Output directory**: Mounted at `/app/output` for results
3. **Environment file**: `.env` mounted as read-only at `/app/.env`
4. **Source directory** (when using `run-local`): Mounted at `/app/mount`

## Configuration File Format

Your YAML configuration file should follow this structure:

```yaml
source:
  repo: "https://github.com/user/repo"  # OR
  local_dir: "/app/mount"               # for local directories

project:
  name: "My Project"
  output_dir: "output"
  language: "english"

file_processing:
  max_file_size: 100000
  include_patterns:
    - "*.py"
    - "*.js"
    - "*.md"
  exclude_patterns:
    - "*test*"
    - "node_modules/*"

analysis:
  max_abstractions: 10
  abstractions_hints:
    - "authentication"
    - "data processing"

llm:
  use_cache: true

github:
  token: "${GITHUB_TOKEN}"  # Will use environment variable
```

## Environment Variables

Create a `.env` file in your project root:

```bash
# .env
GITHUB_TOKEN=your_github_token_here
OPENAI_API_KEY=your_openai_api_key_here
# Add other required environment variables
```

## Troubleshooting

### Common Issues

1. **Configuration file not found**
   ```bash
   make run CONFIG_FILE=path/to/your/config.yaml
   ```

2. **Permission denied for output directory**
   ```bash
   sudo chown -R $USER:$USER ./output
   ```

3. **Docker build fails**
   ```bash
   make clean
   make build DOCKER_BUILD_ARGS="--no-cache --pull"
   ```

4. **Registry push fails**
   ```bash
   docker login
   make push REGISTRY_USER=your_actual_username
   ```

### Debug Mode

Use debug mode to troubleshoot issues:

```bash
make run-debug CONFIG_FILE=configs/my_config.yaml

# Inside the container:
python main.py config.yaml --validate-only
python main.py config.yaml
```

## Advanced Usage

### Custom Docker Build Args
```bash
make build DOCKER_BUILD_ARGS="--build-arg PYTHON_VERSION=3.11"
```

### Multiple Configurations
```bash
# Process multiple projects
for config in configs/*.yaml; do
    echo "Processing $config"
    make run CONFIG_FILE="$config"
done
```

### CI/CD Integration
```bash
# In your CI pipeline
make build
make test
make push REGISTRY_USER=$CI_REGISTRY_USER
```



<h1 align="center">Turns Codebase into Easy Tutorial with AI</h1>

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
 <a href="https://discord.gg/hUHHE9Sa6T">
    <img src="https://img.shields.io/discord/1346833819172601907?logo=discord&style=flat">
</a>
> *Ever stared at a new codebase written by others feeling completely lost? This tutorial shows you how to build an AI agent that analyzes GitHub repositories and creates beginner-friendly tutorials explaining exactly how the code works.*

<p align="center">
  <img
    src="./assets/banner.png" width="800"
  />
</p>

This is a tutorial project of [Pocket Flow](https://github.com/The-Pocket/PocketFlow), a 100-line LLM framework. It crawls GitHub repositories and builds a knowledge base from the code. It analyzes entire codebases to identify core abstractions and how they interact, and transforms complex code into beginner-friendly tutorials with clear visualizations.

- Check out the [YouTube Development Tutorial](https://youtu.be/AFY67zOpbSo) for more!

- Check out the [Substack Post Tutorial](https://zacharyhuang.substack.com/p/ai-codebase-knowledge-builder-full) for more!

&nbsp;&nbsp;**🔸 🎉 Reached Hacker News Front Page** (April 2025) with >900 up‑votes:  [Discussion »](https://news.ycombinator.com/item?id=43739456)

&nbsp;&nbsp;**🔸 🎊 Online Service Now Live!** (May&nbsp;2025) Try our new online version at [https://code2tutorial.com/](https://code2tutorial.com/) – just paste a GitHub link, no installation needed!

## ⭐ Example Results for Popular GitHub Repositories!

<p align="center">
    <img
      src="./assets/example.png" width="600"
    />
</p>

🤯 All these tutorials are generated **entirely by AI** by crawling the GitHub repo!

- [AutoGen Core](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/AutoGen%20Core) - Build AI teams that talk, think, and solve problems together like coworkers!

- [Browser Use](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Browser%20Use) - Let AI surf the web for you, clicking buttons and filling forms like a digital assistant!

- [Celery](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Celery) - Supercharge your app with background tasks that run while you sleep!

- [Click](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Click) - Turn Python functions into slick command-line tools with just a decorator!

- [Codex](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Codex) - Turn plain English into working code with this AI terminal wizard!

- [Crawl4AI](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Crawl4AI) - Train your AI to extract exactly what matters from any website!

- [CrewAI](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/CrewAI) - Assemble a dream team of AI specialists to tackle impossible problems!

- [DSPy](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/DSPy) - Build LLM apps like Lego blocks that optimize themselves!

- [FastAPI](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/FastAPI) - Create APIs at lightning speed with automatic docs that clients will love!

- [Flask](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Flask) - Craft web apps with minimal code that scales from prototype to production!

- [Google A2A](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Google%20A2A) - The universal language that lets AI agents collaborate across borders!

- [LangGraph](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/LangGraph) - Design AI agents as flowcharts where each step remembers what happened before!

- [LevelDB](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/LevelDB) - Store data at warp speed with Google's engine that powers blockchains!

- [MCP Python SDK](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/MCP%20Python%20SDK) - Build powerful apps that communicate through an elegant protocol without sweating the details!

- [NumPy Core](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/NumPy%20Core) - Master the engine behind data science that makes Python as fast as C!

- [OpenManus](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/OpenManus) - Build AI agents with digital brains that think, learn, and use tools just like humans do!

- [PocketFlow](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/PocketFlow) - 100-line LLM framework. Let Agents build Agents!

- [Pydantic Core](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Pydantic%20Core) - Validate data at rocket speed with just Python type hints!

- [Requests](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/Requests) - Talk to the internet in Python with code so simple it feels like cheating!

- [SmolaAgents](https://the-pocket.github.io/PocketFlow-Tutorial-Codebase-Knowledge/SmolaAgents) - Build tiny AI agents that punch way above their weight class!

- Showcase Your AI-Generated Tutorials in [Discussions](https://github.com/The-Pocket/PocketFlow-Tutorial-Codebase-Knowledge/discussions)!

## 🚀 Getting Started

1. Clone this repository
   ```bash
   git clone https://github.com/The-Pocket/PocketFlow-Tutorial-Codebase-Knowledge
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Set up LLM in [`utils/call_llm.py`](./utils/call_llm.py) by providing credentials. To do so, you can put the values in a `.env` file. By default, you can use the AI Studio key with this client for Gemini Pro 2.5 by setting the `GEMINI_API_KEY` environment variable. If you want to use another LLM, you can set the `LLM_PROVIDER` environment variable (e.g. `XAI`), and then set the model, url, and API key (e.g. `XAI_MODEL`, `XAI_URL`,`XAI_API_KEY`). If using Ollama, the url is `http://localhost:11434/` and the API key can be omitted.
   You can use your own models. We highly recommend the latest models with thinking capabilities (Claude 3.7 with thinking, O1). You can verify that it is correctly set up by running:
   ```bash
   python utils/call_llm.py
   ```

5. Generate a complete codebase tutorial by running the main script:
    ```bash
    # Analyze a GitHub repository
    python main.py --repo https://github.com/username/repo --include "*.py" "*.js" --exclude "tests/*" --max-size 50000

    # Or, analyze a local directory
    python main.py --dir /path/to/your/codebase --include "*.py" --exclude "*test*"

    # Or, generate a tutorial in Chinese
    python main.py --repo https://github.com/username/repo --language "Chinese"
    ```

    - `--repo` or `--dir` - Specify either a GitHub repo URL or a local directory path (required, mutually exclusive)
    - `-n, --name` - Project name (optional, derived from URL/directory if omitted)
    - `-t, --token` - GitHub token (or set GITHUB_TOKEN environment variable)
    - `-o, --output` - Output directory (default: ./output)
    - `-i, --include` - Files to include (e.g., "`*.py`" "`*.js`")
    - `-e, --exclude` - Files to exclude (e.g., "`tests/*`" "`docs/*`")
    - `-s, --max-size` - Maximum file size in bytes (default: 100KB)
    - `--language` - Language for the generated tutorial (default: "english")
    - `--max-abstractions` - Maximum number of abstractions to identify (default: 10)
    - `--no-cache` - Disable LLM response caching (default: caching enabled)

The application will crawl the repository, analyze the codebase structure, generate tutorial content in the specified language, and save the output in the specified directory (default: ./output).


<details>
 
<summary> 🐳 <b>Running with Docker</b> </summary>

To run this project in a Docker container, you'll need to pass your API keys as environment variables. 

1. Build the Docker image
   ```bash
   docker build -t pocketflow-app .
   ```

2. Run the container

   You'll need to provide your `GEMINI_API_KEY` for the LLM to function. If you're analyzing private GitHub repositories or want to avoid rate limits, also provide your `GITHUB_TOKEN`.
   
   Mount a local directory to `/app/output` inside the container to access the generated tutorials on your host machine.
   
   **Example for analyzing a public GitHub repository:**
   
   ```bash
   docker run -it --rm \
     -e GEMINI_API_KEY="YOUR_GEMINI_API_KEY_HERE" \
     -v "$(pwd)/output_tutorials":/app/output \
     pocketflow-app --repo https://github.com/username/repo
   ```
   
   **Example for analyzing a local directory:**
   
   ```bash
   docker run -it --rm \
     -e GEMINI_API_KEY="YOUR_GEMINI_API_KEY_HERE" \
     -v "/path/to/your/local_codebase":/app/code_to_analyze \
     -v "$(pwd)/output_tutorials":/app/output \
     pocketflow-app --dir /app/code_to_analyze
   ```
</details>

## 💡 Development Tutorial

- I built using [**Agentic Coding**](https://zacharyhuang.substack.com/p/agentic-coding-the-most-fun-way-to), the fastest development paradigm, where humans simply [design](docs/design.md) and agents [code](flow.py).

- The secret weapon is [Pocket Flow](https://github.com/The-Pocket/PocketFlow), a 100-line LLM framework that lets Agents (e.g., Cursor AI) build for you

- Check out the Step-by-step YouTube development tutorial:

<br>
<div align="center">
  <a href="https://youtu.be/AFY67zOpbSo" target="_blank">
    <img src="./assets/youtube_thumbnail.png" width="500" alt="Pocket Flow Codebase Tutorial" style="cursor: pointer;">
  </a>
</div>
<br>



