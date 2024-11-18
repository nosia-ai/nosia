# Nosia

Nosia is a platform that allows you to run an AI model on your own data.
It is designed to be easy to install and use.

## Easy to install

<https://github.com/nosia-ai/nosia/assets/1692273/671ccb6a-054c-4dc2-bcd9-2b874a888548>

## Easy to use

<https://github.com/nosia-ai/nosia/assets/1692273/ce60094b-abb5-4ed4-93aa-f69485e058b0>

## macOS, Debian or Ubuntu one command installation

It will install Docker, Ollama, and Nosia on a macOS, Debian or Ubuntu machine.

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

## macOS installation with a Debian or Ubuntu VM

On macOS, install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install Ollama with Homebrew:

Replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
brew install ollama
ollama pull qwen2.5
ollama pull bespoke-minicheck
ollama pull nomic-embed-text
OLLAMA_BASE_URL=<HOST_IP>:11434 OLLAMA_MAX_LOADED_MODELS=3 ollama serve
```

On the Debian/Ubuntu VM:

Replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/nosia-ai/nosia-install/main/nosia-install.sh | OLLAMA_BASE_URL=http://<HOST_IP>:11434 sh
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

By default, Nosia uses the `qwen2.5` completion model, the `nomic-embed-text` embeddings model and the `bespoke-minicheck` checking model.

You can use any completion model available on Ollama by setting the `LLM_MODEL` environment variables during the installation.

For example, to use the `mistral` model, replace `<HOST_IP>` with the IP address of the host machine and run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/nosia-ai/nosia-install/main/nosia-install.sh | OLLAMA_BASE_URL=http://<HOST_IP>:11434 LLM_MODEL=mistral sh
```

### Custom embeddings model

At this time, the `nomic-embed-text` embeddings model is required for Nosia to work.

## Starting, upgrading, and stopping the services

You can start, upgrade and stop the services with the following commands:

```bash
cd nosia
./script/start
./script/upgrade
./script/stop
```

## OpenAI chat compatible API

1. Go as a logged in user to <https://nosia.localhost/api_tokens>

2. Generate and copy your token

3. Use your favorite OpenAI chat API client by configuring API base to `https://nosia.localhost/v1` and API key with your token.

### Try the API

1. Install HTTPie CLI or use any HTTP client of your choice:

2. Try the stream API by creating a `test-stream.json` file with the following content:

```json
{"messages":[{"role":"user","content":"When Ruby 3.3.7 will be released?"}],"model":"qwen2.5","stream":true,"top_p":0.9,"top_k":40.0,"temperature":0.1}
```

3. Replace `<token>` with your token and run the following command:

```sh
http -A bearer -a <token> --stream POST https://nosia.localhost/v1/completions < test-stream.json
```

4. Try the API without streaming by creating a `test-non-stream.json` file with the following content:

```json
{"messages":[{"role":"user","content":"When Ruby 3.3.7 will be released?"}],"model":"qwen2.5","stream":false,"top_p":0.9,"top_k":40.0,"temperature":0.1}
```

5. Replace `<token>` with your token and run the following command:

```sh
http -A bearer -a <token> POST https://nosia.localhost/v1/completions < test-non-stream.json
```

## Continue.dev integration

1. In your `~/.continue/config.json`, configure a `nosia` model:

```json
  "models": [
    {
      "model": "nosia",
      "provider": "openai",
      "apiBase": "https://nosia.localhost/v1",
      "apiKey": "token",
      "title": "Nosia"
    }
  ]
```

2. Enjoy!

## Troubleshooting

If you encounter any issue:

- during the installation, you can check the logs at `./log/production.log`
- during the use waiting for an AI response, you can check the jobs at `http://<IP>:3000/jobs`
- with Nosia, you can check the logs with `docker compose -f ./docker-compose.yml logs -f`
- with the Ollama server, you can check the logs at `~/.ollama/logs/server.log`

If you need further assistance, please open an issue!
