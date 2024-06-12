# Nosia

Nosia is a platform that allows you to run an AI model on your own data.
It is designed to be easy to install and use.
It is composed of two parts: Ollama, and Nosia.

## Debian/Ubuntu full one command installation

```bash
curl -fsSL https://gitd.fr/-/snippets/1/raw/main/ia.sh | RAILS_MASTER_KEY=<KEY> sh
```

## macOS installation with Debian/Ubuntu VM

On macOS, install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install Ollama with Homebrew:

Replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
brew install ollama
OLLAMA_URL=<HOST_IP>:11434 ollama
```

On the Debian/Ubuntu VM:

Replace `<HOST_IP>` with the IP address of the host machine and `<KEY>` with the Rails master key) and run the following command:

```bash
curl -fsSL https://gitd.fr/-/snippets/1/raw/main/ia.sh | OLLAMA_URL=<HOST_IP>:11434 RAILS_MASTER_KEY=<KEY> sh
```

You should see the following output:
✅ Setting up environment
✅ Setting up Docker
✅ Setting up Ollama
✅ Starting Ollama
✅ Starting Nosia

Replace `<VM_IP>` with the IP address of the VM and you can now access Nosia at `http://<VM_IP>:3000`

## Starting, upgrading, and stopping the services

You can start and stop the services with the following commands:

```bash
./ia/script/production/start
./ia/script/production/upgrade
./ia/script/production/stop
```

## Troubleshooting

If you encounter any issues during the installation, you can check the logs with the following command:

```
tail -f ./ia/logs/production.log
```

If you encounter any issues with the AI, you can check the jobs at `http://<VM_IP>:3000/jobs`

If you need further assistance, please contact us!

