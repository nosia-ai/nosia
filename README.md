# Nosia

Nosia is a platform that allows you to run an AI model on your own data.
It is designed to be easy to install and use.

## Easy to install

https://github.com/nosia-ai/nosia/assets/1692273/671ccb6a-054c-4dc2-bcd9-2b874a888548

## Easy to use

https://github.com/nosia-ai/nosia/assets/1692273/ce60094b-abb5-4ed4-93aa-f69485e058b0

## Debian/Ubuntu one command installation

It will install Docker, Ollama, and Nosia on a Debian/Ubuntu machine.

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

You can now access Nosia at `https://nosia.localhost`

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

Replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/nosia-ai/nosia-install/main/nosia-install.sh | OLLAMA_URL=http://<HOST_IP>:11434 sh
```

You should see the following output:

```
✅ Setting up environment
✅ Setting up Docker
✅ Setting up Ollama
✅ Starting Ollama
✅ Starting Nosia
```

From the VM, you can access Nosia at `https://nosia.localhost`

If you want to access Nosia from the host machine, you may need to forward the port from the VM to the host machine.

Replace `<USER>` with the username of the VM, `<VM_IP>` with the IP address of the VM, and `<LOCAL_PORT>` with the port you want to use on the host machine, 8443 for example, and run the following command:

```bash
ssh -f <USER>@<VM_IP> -L <LOCAL_PORT>:localhost:443
```

After running the command, you can access Nosia at `https://nosia.localhost:<LOCAL_PORT>`.

## Installation with custom models

### Custom completion model

By default, Nosia uses the `phi3:medium` completion model and the `nomic-embed-text` embeddings model.

You can use any completion model available on Ollama by setting the `OLLAMA_CHAT_COMPLETION_MODEL` and `OLLAMA_COMPLETION_MODEL` environment variables during the installation.

For example, to use the `llama3:latest` model, replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/nosia-ai/nosia-install/main/nosia-install.sh | OLLAMA_URL=http://<HOST_IP>:11434 OLLAMA_CHAT_COMPLETION_MODEL=llama3:latest OLLAMA_COMPLETION_MODEL=llama3:latest sh
```

### Custom embeddings model

At this time, the `nomic-embed-text` embeddings model is required for Nosia to work.

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

If you need further assistance, please open an issue!
