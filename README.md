# quickgpt
quickgpt is a cli tool for easier chat gpt requests. I keep my terminal always open, so it is quicker to just use a cli for easier Q&A. 
Keep in mind it does not keep previous messages as context yet (possible next feature?).

This is my first cli, so if you have sugegstions please let me know! And thanks for exploring it's capabilities!

## Installation

### Manual Installation
Download or clone the repo, and inside it's root execute the following:
```
swift build --configuration release && cp -f .build/release/quickgpt /usr/local/bin/quickgpt
```
This will respectively build the cli package as an executable and then move it to where your other terminal commands are.


## Usage
just use `quickgpt -h` for help or a quick use as:
```
quickgpt -m <gpt-model> -k <your-API-key> "why is the sky blue?"
```
You can set your default model and default API key used with the respective commands: `quickgpt set-model <model>` and `quickgpt set-api-key <key>`. Your key will be securely stored on the keychain.
For a list of available models check [OpenAIs list](https://platform.openai.com/docs/models). Only text models available.

You can also not stream the result with the `-s` argument like in 
```
quickgpt "why is the sky blue?" -s false
```
