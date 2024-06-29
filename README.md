# Nosia

Nosia is a platform that allows you to run an AI model on your own data.
It is designed to be easy to install and use.

## Debian/Ubuntu one command installation

```bash
curl -fsSL https://raw.githubusercontent.com/nosia-ai/nosia-install/main/nosia-install.sh | sh
```

You should see the following output:

```
✅ Setting up environment
✅ Setting up Docker
✅ Setting up Ollama
✅ Starting Ollama
✅ Starting Nosia
```

You can now access Nosia at `http://localhost:3000`

## macOS installation with Debian/Ubuntu VM

On macOS, install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install Ollama with Homebrew:

Replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
brew install ollama
ollama pull phi3:medium
ollama pull nomic-embed-text
OLLAMA_URL=<HOST_IP>:11434 OLLAMA_NUM_PARALLEL=3 OLLAMA_MAX_LOADED_MODELS=2 ollama serve
```

On the Debian/Ubuntu VM:

Replace `<HOST_IP>` with the IP address of the host machine and `<KEY>` with the Rails master key and run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/nosia-ai/nosia-install/main/nosia-install.sh | OLLAMA_URL=<HOST_IP>:11434 sh
```

You should see the following output:

```
✅ Setting up environment
✅ Setting up Docker
✅ Setting up Ollama
✅ Starting Ollama
✅ Starting Nosia
```

Replace `<VM_IP>` with the IP address of the VM and you can now access Nosia at `http://<VM_IP>:3000`

## Installation with custom completion models

You can use any completion model available on Ollama by setting the `OLLAMA_CHAT_COMPLETION_MODEL` and `OLLAMA_COMPLETION_MODEL` environment variables during the installation.

For example, to use the `llama3:latest` model, replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/nosia-ai/nosia-install/main/nosia-install.sh | OLLAMA_URL=<HOST_IP>:11434 OLLAMA_CHAT_COMPLETION_MODEL=llama3:latest OLLAMA_COMPLETION_MODEL=llama3:latest sh
```

## Starting, upgrading, and stopping the services

You can start, upgrade and stop the services with the following commands:

```bash
cd nosia
./script/production/start
./script/production/upgrade
./script/production/stop
```

## Troubleshooting

If you encounter any issue:
- during the installation, you can check the logs at `./log/production.log`
- during the use waiting for an AI response, you can check the jobs at `http://<IP>:3000/jobs`
- with Nosia, you can check the logs with `docker compose -f ./docker-compose.yml logs -f`
- with the Ollama server, you can check the logs at `~/.ollama/logs/server.log`

If you need further assistance, please contact us!
