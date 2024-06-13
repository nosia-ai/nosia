# Nosia

Nosia is a platform that allows you to run an AI model on your own data.
It is designed to be easy to install and use.

## Debian/Ubuntu one command installation

```bash
curl -fsSL https://gitd.fr/-/snippets/1/raw/main/ia.sh | RAILS_MASTER_KEY=<KEY> sh
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

## macOS installation with Debian/Ubuntu VM

On macOS, install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install Ollama with Homebrew:

Replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
brew install ollama
ollama pull mistral
OLLAMA_URL=<HOST_IP>:11434 ollama run mistral
```

On the Debian/Ubuntu VM:

Replace `<HOST_IP>` with the IP address of the host machine and `<KEY>` with the Rails master key and run the following command:

```bash
curl -fsSL https://gitd.fr/-/snippets/1/raw/main/ia.sh | OLLAMA_URL=<HOST_IP>:11434 RAILS_MASTER_KEY=<KEY> sh
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

## Starting, upgrading, and stopping the services

You can start and stop the services with the following commands:

```bash
./ia/script/production/start
./ia/script/production/upgrade
./ia/script/production/stop
```

## Troubleshooting

If you encounter any issue:
- during the installation, you can check the logs at `./ia/log/production.log`
- during the use waiting for an AI response, you can check the jobs at `http://<VM_IP>:3000/jobs`
- with Nosia, you can check the logs with `docker compose -f ./ia/docker-compose.yml logs -f`
- with the Ollama server, you can check the logs at `~/.ollama/logs/server.log`

If you need further assistance, please contact us!
